"""

HttpCtrl library provides HTTP/HTTPS client and server API to Robot Framework to make REST API testing easy.

Authors: Andrei Novikov
Date: 2018-2022
Copyright: The 3-Clause BSD License

"""

from threading import Lock
import json
from urllib.parse import parse_qs
from HttpCtrl.utils.singleton import Singleton


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
                if '?' in stub.criteria.url:
                    stub_url_components = stub.criteria.url.split('?')

                    # the last slash should be removed (on BOTH sides — a stub
                    # registered with a trailing `/` must still match a request
                    # whose path also ends with `/`)
                    criteria_url = criteria_url_components[0].rstrip("/")
                    if criteria_url != stub_url_components[0].rstrip("/"):
                        return False

                    # extraction of attributes from the response body (only works when response body is a dictionary)
                    # return an empty array if response body is an array
                    parsed_body = json.loads(stub.response.get_body())
                    if isinstance(parsed_body, list):
                        attributes = []
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
                        if param not in criteria_url_components[1]:
                            return False
                    return True
                
                # we should check if an id is into the url
                if "urn" in stub.criteria.url:
                    stub_url = stub.criteria.url.split("/")
                    id = stub_url[-1].split(":")
                    for elements in id:
                        if elements not in (criteria.url):
                            return False
                    return True
                else:
                    return False
            
            # if the method is not GET, we should ignore parameters and check if the url is the same
            else:
                if stub.criteria.url.rstrip("/") == criteria_url_components[0].rstrip("/"):
                    # if the request is a query via POST, we should have a specific check
                    if stub.criteria.url == "/ngsi-ld/v1/entityoperations/query":
                        response_body = json.loads(stub.response.get_body())
                        body_str = body.decode('utf-8')
                        request_body = json.loads(body_str)
                        # check if the request body contains the same type as the response body
                        if "type" in request_body["entities"][0] or "id" in request_body["entities"][0]:
                            if request_body["entities"][0]["type"] != response_body["type"]:
                                return False
                            if request_body["entities"][0]["id"] != response_body["id"]:
                                return False
                        else:
                            return False
                    return True
        
        if stub.criteria.url.rstrip("/") == criteria.url.rstrip("/"):
            # if the request is a query via POST, we should have a specific check
            if stub.criteria.url == "/ngsi-ld/v1/entityoperations/query":
                response_body = json.loads(stub.response.get_body())
                body_str = body.decode('utf-8')
                request_body = json.loads(body_str)
                # check if the request body contains the same type as the response body
                if "type" in request_body["entities"][0] or "id" in request_body["entities"][0]:
                    if request_body["entities"][0]["type"] != response_body["type"]:
                        return False
                    if request_body["entities"][0]["id"] != response_body["id"]:
                        return False
                else:
                    return False
            return True

        return False