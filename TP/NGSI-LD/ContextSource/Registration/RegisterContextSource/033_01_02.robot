*** Settings ***
Documentation       Check that you can create a context source registration that never expires

Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistration.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceDiscovery.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Teardown      Delete Created Context Source Registrations


*** Variables ***
${registration_id_prefix}=              urn:ngsi-ld:Registration:
${registration_payload_file_path}=      csourceRegistrations/context-source-registration-simple-sample.jsonld


*** Test Cases ***
033_01_02 Create Context Source Registration That Never Expires
    [Documentation]    Check that you can create a context source registration that never expires
    [Tags]    csr-create
    ${registration_id}=    Generate Random Entity Id    ${registration_id_prefix}
    Set Suite Variable    ${registration_id}
    ${payload}=    Load JSON From File    ${EXECDIR}/data/${registration_payload_file_path}
    ${registration_payload}=    Update Value To JSON    ${payload}    $..id    ${registration_id}
    ${response}=    Create Context Source Registration With Return    ${registration_payload}
    Check Response Status Code    201    ${response.status_code}
    Check Response Headers Containing URI set to    ${registration_id}    ${response.headers}
    ${response}=    Retrieve Context Source Registration
    ...    ${registration_id}
    ...    context=${ngsild_test_suite_context}
    ...    accept=${CONTENT_TYPE_LD_JSON}
    ${ignored_attributes}=    Create List    ${status_regex_expr}
    Check Created Resource Set To    ${registration_payload}    ${response.json()}    ${ignored_attributes}


*** Keywords ***
Delete Created Context Source Registrations
    Delete Context Source Registration    ${registration_id}
