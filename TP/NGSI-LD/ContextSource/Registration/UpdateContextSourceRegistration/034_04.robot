*** Settings ***
Documentation       Check that you cannot update a context source registration under some conditions

Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistration.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Create Initial Context Source Registration
Test Teardown       Delete Initial Context Source Registration


*** Variables ***
${registration_id_prefix}=              urn:ngsi-ld:Registration:
${filename}=                            context-source-registration-sample.jsonld
${registration_payload_file_path}=      context-source-registration-invalid-sample.jsonld


*** Test Cases ***
034_04_01 Update a context source registration if the request body is invalid
    [Documentation]    Check that you cannot update a context source registration if the request body is invalid
    [Tags]    csr-update    5_9_3
    ${response}=    Update Context Source Registration
    ...    ${registration_id}
    ...    ${registration_payload_file_path}
    # Check Response Status Code    <Response [400]>    ${response.json()}
    Check Response Status Code    400    ${response.status_code}
    Check Response Body Type When Using Session Request    ${response.json()}    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Title When Using Session Request    ${response.json()}


*** Keywords ***
Create Initial Context Source Registration
    ${valid_registration_id}=    Generate Random Entity Id    ${registration_id_prefix}
    Set Test Variable    ${valid_registration_id}
    ${registration_id}=    Generate Random Entity Id    ${registration_id_prefix}
    Set Test Variable    ${registration_id}
    ${payload}=    Load JSON From File    ${EXECDIR}/data/csourceRegistrations/${filename}
    ${updated_payload}=    Update Value To JSON    ${payload}    $..id    ${registration_id}
    ${response}=    Create Context Source Registration With Return    ${updated_payload}
    Check Response Status Code    201    ${response.status_code}

Delete Initial Context Source Registration
    Delete Context Source Registration    ${registration_id}
