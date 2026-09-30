"""

HttpCtrl library provides HTTP/HTTPS client and server API to Robot Framework to make REST API testing easy.

Authors: Andrei Novikov
Date: 2018-2022
Copyright: The 3-Clause BSD License

"""

from threading import Lock
import json
from urllib.parse import parse_qs, unquote
from HttpCtrl.utils.singleton import Singleton


def _same_type(requested, stubbed):
    # The mock does not read @context. So when the broker sends the full
    # type IRI (https://ngsi-ld-test-suite/context#Vehicle), compare only
    # the last part of it (Vehicle).
    if not isinstance(requested, str) or not isinstance(stubbed, str):
        return requested == stubbed
    return requested == stubbed or requested.endswith("#" + stubbed) or requested.endswith("/" + stubbed)


def _query_reply_matches(reply_text, request_bytes):
    # A POST /entityOperations/query stub matches when one entity in its
    # response body (an object or an array) fits the first entity selector
    # of the request.
    if request_bytes is None:
        # count() finds a stub by method and URL only, without a request body.
        return True
    try:
        selector = json.loads(request_bytes.decode('utf-8'))["entities"][0]
    except (ValueError, KeyError, IndexError, TypeError, AttributeError):
        return False
    if not isinstance(selector, dict) or ("type" not in selector and "id" not in selector):
        return False
    reply = json.loads(reply_text)
    ids = selector.get("id") if isinstance(selector.get("id"), list) else [selector.get("id")]
    for entity in (reply if isinstance(reply, list) else [reply]):
        if not isinstance(entity, dict):
            continue
        if "type" in selector and not _same_type(selector["type"], entity.get("type")):
            continue
        if "id" in selector and entity.get("id") not in ids:
            continue
        return True
    return False


class HttpStubCriteria:
    def __init__(self, **kwargs):
        self.method = kwargs.get('method', None)
        if self.method is not None:
            self.method = self.method.upper()

        self.url = kwargs.get('url', None)
        if self.url is not None:
            self.url = self.url.lower()


    def __eq__(self, other):
        return (self.method == other.method) and (self.url == other.url)


class HttpStub:
    def __init__(self, criteria, response):
        self.criteria = criteria
        self.response = response
        self.count = 0


class HttpStubContainer(metaclass=Singleton):
    def __init__(self):
        self.__stubs = []
        self.__lock = Lock()


    def add(self, criteria, response):
        with self.__lock:
            self.__stubs.append(HttpStub(criteria, response))


    def count(self, criteria):
        with self.__lock:
            for stub in self.__stubs:
                if self.__is_satisfy(stub, criteria) is True:
                    return stub.count
            
            return 0


    def get(self, criteria, body):
        with self.__lock:
            for stub in self.__stubs:
                if self.__is_satisfy(stub, criteria, body) is True:
                    stub.count += 1
                    return stub
        
            return None


    def clear(self):
        with self.__lock:
            self.__stubs.clear()

    def __is_satisfy(self, stub, criteria, body=None):

        if stub.criteria.method != criteria.method:
            return False
        
        
        if '?' in criteria.url:
            # url should be divided into two parts, the former is the endpoint, while the latter refers to the parameters
            criteria_url_components = criteria.url.split('?')
            
            # distribution brokers may add optional parameters to the url, so we should check if the url is valid even though it is not the same as the stub's url
            if criteria.method == "GET":
                # Decode the query first. A broker may percent-encode values
                # (id=urn%3Angsi-ld%3A...). This is the same query as the stub's
                # id=urn:ngsi-ld:..., but the text checks below would not find it.
                criteria_query = unquote(criteria_url_components[1])
                if '?' in stub.criteria.url:
                    stub_url_components = stub.criteria.url.split('?')

                    # the last slash should be removed (on BOTH sides — a stub
                    # registered with a trailing `/` must still match a request
                    # whose path also ends with `/`)
                    criteria_url = criteria_url_components[0].rstrip("/")
                    if criteria_url != stub_url_components[0].rstrip("/"):
                        return False

                    # Collect the attribute names from the response body. If the body
                    # is an array (a query response always is), use the names of all
                    # entities in it.
                    parsed_body = json.loads(stub.response.get_body())
                    if isinstance(parsed_body, list):
                        attributes = [key.lower() for item in parsed_body if isinstance(item, dict) for key in item]
                    else:
                        attributes = [key.lower() for key in parsed_body]
                    # criteria parameters should be separated to check if attributes are into the response body
                    if ('attrs' in parse_qs(criteria_url_components[1])):
                        criteria_parse = parse_qs(criteria_url_components[1])['attrs']
                        criteria_attributes = [element for attr in criteria_parse for element in attr.split(",")]
                        for attr in criteria_attributes:
                            if attr not in attributes:
                                return False

                    # stub's parameters should be separated to check if they are into the received request
                    stub_params = stub_url_components[1].split("&")
                    # Flatten the list to get a list of key-value elements
                    stub_params_components = [element for param in stub_params for element in param.split("=")]
                    for param in stub_params_components:
                        if param not in criteria_query:
                            return False
                    return True
                
                # we should check if an id is into the url
                if "urn" in stub.criteria.url:
                    # some brokers keep the id as the last path segment and
                    # only append extra query params (e.g. .../entities/{id}?sysAttrs=true);
                    # in that case the stub's full url (id included) already
                    # matches the request path as-is
                    if criteria_url_components[0].rstrip("/") == stub.criteria.url.rstrip("/"):
                        return True

                    # other brokers drop the id from the path entirely and
                    # send it as a query parameter instead (e.g. distributed
                    # retrieveEntity forwarded as GET .../entities?id=...&type=...);
                    # there the base path (id excluded) must still match
                    # exactly so a request to broker2 can't be satisfied by a
                    # stub registered for broker1 (or vice versa), and the id
                    # pieces are looked for in the query string instead
                    stub_url = stub.criteria.url.split("/")
                    stub_prefix = "/".join(stub_url[:-1]).rstrip("/")
                    if criteria_url_components[0].rstrip("/") != stub_prefix:
                        return False

                    id = stub_url[-1].split(":")
                    for elements in id:
                        if elements not in criteria_query:
                            return False
                    return True
                else:
                    return False
            
            # if the method is not GET, we should ignore parameters and check if the url is the same
            else:
                # The stub has a query, for example D017_01_inc:
                #   DELETE /entities?type=Vehicle&id=...
                # The check below compares the stub with the request path only, so it
                # is never true for such a stub. Then the full URLs are compared as
                # plain text, and a percent-encoded id (id=urn%3Angsi-ld%3A...) never
                # matches id=urn:ngsi-ld:... Both are the same query, so compare the
                # decoded parameters.
                stub_path, _, stub_query = stub.criteria.url.partition('?')
                if stub_query and \
                        stub_path.rstrip("/") == criteria_url_components[0].rstrip("/") and \
                        parse_qs(stub_query) == parse_qs(criteria_url_components[1]):
                    return True
                if stub.criteria.url.rstrip("/") == criteria_url_components[0].rstrip("/"):
                    # if the request is a query via POST, we should have a specific check
                    if stub.criteria.url == "/ngsi-ld/v1/entityoperations/query":
                        return _query_reply_matches(stub.response.get_body(), body)
                    return True
        
        if stub.criteria.url.rstrip("/") == criteria.url.rstrip("/"):
            # if the request is a query via POST, we should have a specific check
            if stub.criteria.url == "/ngsi-ld/v1/entityoperations/query":
                return _query_reply_matches(stub.response.get_body(), body)
            return True

        return False