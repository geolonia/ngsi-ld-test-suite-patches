*** Settings ***
Documentation       Check that you can create a context source registration without specifying an ID

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource


*** Variables ***
${registration_id_prefix}=              urn:ngsi-ld:Registration:
${registration_payload_file_path}=      csourceRegistrations/context-source-registration-no-id-sample.jsonld


*** Test Cases ***
Create Context Source Registration Without A Sprecified ID
    [Documentation]    Check that you can create a context source registration without specifying an ID
    [Tags]    csr-create
    ${payload}=    Load JSON From File    ${EXECDIR}/data/${registration_payload_file_path}
    ${request}    ${response}=    Create Context Source Registration With Return    ${payload}
    Check Response Status Code    201    ${response['status']}
    ${registration_id}=    Check Response Headers ID Not Empty    ${response}
    ${registration_payload}=    Update Value To JSON    ${payload}    $..id    ${registration_id}
    Retrieve Context Source Registration
    ...    ${registration_id}
    ...    context=${ngsild_test_suite_context}
    ...    accept=${CONTENT_TYPE_LD_JSON}
    ${ignored_attributes}=    Create List    ${status_regex_expr}
    Check Created Resource Set To    ${registration_payload}    ${ignored_attributes}
    [Teardown]    Delete Context Source Registration    ${registration_id}
