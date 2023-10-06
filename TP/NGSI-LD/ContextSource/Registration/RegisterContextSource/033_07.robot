*** Settings ***
Documentation       Check that the @context is obtained from the request payload body itself if the Content-Type header is "application/ld+json"

Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistration.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceDiscovery.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Teardown      Delete Created Context Source Registrations


*** Variables ***
${registration_id_prefix}=              urn:ngsi-ld:Registration:
${registration_payload_file_path}=      csourceRegistrations/context-source-registration-sample.jsonld


*** Test Cases ***
033_07_01 Create one context source registration using a JSON-LD @context obtained from the request payload
    [Documentation]    Check that the @context is obtained from the request payload body itself if the Content-Type header is "application/ld+json"
    [Tags]    csr-create    6_3_5
    ${registration_id}=    Generate Random Entity Id    ${registration_id_prefix}
    Set Suite Variable    ${registration_id}
    ${payload}=    Load JSON From File    ${EXECDIR}/data/${registration_payload_file_path}
    ${updated_payload}=    Update Value To JSON    ${payload}    $..id    ${registration_id}
    ${response}=    Create Context Source Registration With Return
    ...    ${updated_payload}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Retrieve Context Source Registration    ${registration_id}    context=${ngsild_test_suite_context}
    Check JSON Value In Response Body    ['information'][0]['entities'][0]['type']    Building    ${response.json()}
    ${response}=    Retrieve Context Source Registration    ${registration_id}
    Check JSON Value In Response Body
    ...    ['information'][0]['entities'][0]['type']
    ...    https://ngsi-ld-test-suite/context#Building
    ...    ${response.json()}


*** Keywords ***
Delete Created Context Source Registrations
    Delete Context Source Registration    ${registration_id}
