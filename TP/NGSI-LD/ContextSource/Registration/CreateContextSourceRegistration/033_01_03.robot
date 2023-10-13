*** Settings ***
Documentation       Check that you can create a context source registration without specifying an ID

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Teardown      Delete Created Context Source Registrations


*** Variables ***
${registration_id_prefix}=              urn:ngsi-ld:Registration:
${registration_payload_file_path}=      csourceRegistrations/context-source-registration-no-id-sample.jsonld


*** Test Cases ***
033_01_03 Create Context Source Registration Without A Sprecified ID
    [Documentation]    Check that you can create a context source registration without specifying an ID
    [Tags]    csr-create    5_9_2
    ${payload}=    Load JSON From File    ${EXECDIR}/data/${registration_payload_file_path}
    ${response}=    Create Context Source Registration With Return    ${payload}
    Check Response Status Code    201    ${response.status_code}
    ${registration_id}=    Check Response Headers ID Not Empty    ${response.headers}
    Set Suite Variable    ${registration_id}
    ${registration_payload}=    Update Value To JSON    ${payload}    $..id    ${registration_id}
    ${response}=    Retrieve Context Source Registration
    ...    context_source_registration_id=${registration_id}
    ...    context=${ngsild_test_suite_context}
    ...    accept=${CONTENT_TYPE_LD_JSON}
    ${ignored_attributes}=    Create List    ${status_regex_expr}
    Check Created Resource Set To    ${registration_payload}    ${response.json()}    ${ignored_attributes}


*** Keywords ***
Delete Created Context Source Registrations
    Delete Context Source Registration    ${registration_id}
