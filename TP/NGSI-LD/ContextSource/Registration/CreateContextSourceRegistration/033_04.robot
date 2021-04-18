*** Settings ***
Documentation     Check that the @context is obtained from a Link Header if the Content-Type header is "application/json"
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${registration_id_prefix}=    urn:ngsi-ld:Registration:
${registration_payload_file_path}=    csourceRegistrations/context-source-registration-sample.json

*** Test Case ***
Create one context source registration using a provided Link header with JSON content type
    [Documentation]    Check that the @context is obtained from a Link Header if the Content-Type header is "application/json"
    [Tags]    csr-create    6_3_5
    ${registration_id}=    Generate Random Entity Id    ${registration_id_prefix}
    ${payload}=    Load Json From File    ${EXECDIR}/data/${registration_payload_file_path}
    ${updated_payload}=    Update Value To Json    ${payload}    $..id    ${registration_id}
    ${request}    ${response}=    Create Context Source Registration With Return    ${updated_payload}    ${CONTENT_TYPE_JSON}    ${ngsild_test_suite_context}
    Check Response Status Code    201    ${response['status']}
    Retrieve Context Source Registration    ${registration_id}    context=${ngsild_test_suite_context}
    Check JSON Value In Response Body    ['information']['entities'][0]['type']    Building
    Retrieve Context Source Registration    ${registration_id}
    Check JSON Value In Response Body    ['information']['entities'][0]['type']    https://ngsi-ld-test-suite/context#Building
    [Teardown]    Delete Context Source Registration    ${registration_id}
