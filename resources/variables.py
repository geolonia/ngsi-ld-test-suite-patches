def get_variables(arg=None):
    variables = {
        'url': 'https://broker-ngsi-ld.demeter.ubiwhere.com/ngsi-ld/v1',
        'ngsild_test_suite_context': 'https://raw.githubusercontent.com/easy-global-market/ngsild-api-data-models/feature/add-json-ld-context-for-ngsi-ld-test-suite/ngsi-ld-test-suite/ngsi-ld-test-suite-context.jsonld',
        'notification_server_host': '0.0.0.0',
        'notification_server_port': 8085,
        'context_source_host': '0.0.0.0',
        'context_source_port': 8086
    }
    return variables
    