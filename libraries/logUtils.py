from __future__ import unicode_literals
from __future__ import division
from pygments import highlight, lexers, formatters
from json import dumps, JSONDecodeError, loads
from robot.api import logger
from robot.api.deco import keyword


@keyword(name="Output", tags=("I/O",))
def output(response, console=True):
    """*Request and response are output to terminal and file (in JSON).*
    :param response: response to a request
    :param console: If false, the JSON is not written to terminal. Default is true.
    """

    try:
        if response.request.body is None:
            request_body = response.request.body
        else:
            request_body = loads(response.request.body)
    except JSONDecodeError:
        request_body = response.request.body

    try:
        response_body = response.json()
    except JSONDecodeError:
        response_body = None

    request_json = {'method': response.request.method, 'url': response.request.url,
                    'headers': dict(response.request.headers), 'body': request_body}
    response_json = {'url': response.url, 'headers': dict(response.headers), 'status_code': response.status_code,
                     'reason': response.reason, 'body': response_body}

    pretty_request_json = dumps(request_json, indent=4, sort_keys=False, separators=(",", ": "))
    pretty_response_json = dumps(response_json, indent=4, sort_keys=False, separators=(",", ": "))

    logger.info(pretty_request_json)
    logger.info(pretty_response_json)

    if console:
        pretty_request_json_colored = highlight(
            pretty_request_json, lexers.JsonLexer(), formatters.TerminalFormatter()
        )
        pretty_response_json_colored = highlight(
            pretty_response_json, lexers.JsonLexer(), formatters.TerminalFormatter()
        )

        logger.console(pretty_request_json_colored)
        logger.console(pretty_response_json_colored)
