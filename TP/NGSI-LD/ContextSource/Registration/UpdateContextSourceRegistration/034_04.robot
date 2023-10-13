*** Settings ***
Documentation       Check that you cannot update a context source registration under some conditions

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Setup Initial Entities
Test Template       Update a context source registration if the request body is invalid


*** Variables ***
${registration_id_prefix}=              urn:ngsi-ld:Registration:
${filename}=                            context-source-registration-simple-sample.jsonld
${registration_payload_file_path}=      context-source-registration-invalid-sample.jsonld


*** Test Cases ***
034_04_01 Update a context source registration if the request body is invalid
    Update a context source registration if the request body is invalid


*** Keywords ***
Update a context source registration if the request body is invalid
    [Documentation]    Check that you cannot update a context source registration if the request body is invalid
    [Tags]    csr-update
    ${registration_id}=    Generate Random Entity Id    ${registration_id_prefix}
    ${payload}=    Load JSON From File    ${EXECDIR}/data/csourceRegistrations/${filename}
    ${updated_payload}=    Update Value To JSON    ${payload}    $..id    ${registration_id}
    ${response}=    Create Context Source Registration With Return    ${updated_payload}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Update Context Source Registration
    ...    ${registration_id}
    ...    ${registration_payload_file_path}
    Check Response Status Code    <Response [400]>    ${response.json()}
    Check Response Body Type When Using Session Request    ${response.json()}    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Title When Using Session Request    ${response.json()}
    [Teardown]    Delete Context Source Registration    ${registration_id}

Setup Initial Entities
    ${valid_registration_id}=    Generate Random Entity Id    ${registration_id_prefix}
    Set Suite Variable    ${valid_registration_id}
