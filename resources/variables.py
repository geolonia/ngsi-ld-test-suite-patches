def get_variables(arg=None):
    variables = {
        'url': 'localhost:8080/ngsi-ld/v1',
        'ngsild_test_suite_context': 'https://forge.etsi.org/rep/cim/ngsi-ld-test-suite/-/raw/develop/resources/ngsi-ld-test-suite-context.jsonld',
        'notification_server_host': '0.0.0.0',
        'notification_server_port': 8085,
        'send_notification_server_host': '0.0.0.0',
        'send_notification_server_port': 8085,
        'context_source_host': '0.0.0.0',
        'context_source_port': 8086
    }
    return variables
    