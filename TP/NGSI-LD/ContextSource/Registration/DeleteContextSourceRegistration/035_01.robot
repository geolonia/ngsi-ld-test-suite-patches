*** Settings ***
Documentation       Check that you can delete a context source registration by id

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource


*** Variables ***
${registration_id_prefix}=              urn:ngsi-ld:Registration:
${registration_payload_file_path}=      context-source-registration-simple-sample.jsonld


*** Test Cases ***
035_01_01 Delete a context source registration by id
    [Documentation]    Check that you can delete a context source registration by id
    [Tags]    csr-delete    5_9_4
    ${registration_id}=    Generate Random Entity Id    ${registration_id_prefix}
    ${payload}=    Load JSON From File    ${EXECDIR}/data/csourceRegistrations/${registration_payload_file_path}
    ${updated_payload}=    Update Value To JSON    ${payload}    $..id    ${registration_id}
    ${response}=    Create Context Source Registration With Return    ${updated_payload}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Delete Context Source Registration With Return    ${registration_id}
    Check Response Status Code    204    ${response.status_code}
    ${response}=    Retrieve Context Source Registration
    ...    context_source_registration_id=${registration_id}
    ...    context=${ngsild_test_suite_context}
    Check SUT Not Containing Resource    ${response.status_code}
