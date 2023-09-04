*** Settings ***
Documentation       Check that you cannot create a context source with invalid content

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource


*** Variables ***
${registration_id_prefix}=              urn:ngsi-ld:Registration:
${registration_payload_file_path}=      context-source-registration-invalid-sample.jsonld


*** Test Cases ***
033_02_01_Create a context source registration with invalid JSON file
    [Tags]    csr-create    5_9_2
    Create a context source registration with invalid JSON file

033_02_02_Create a context source registration with a different data structure than CsourRegistration data type
    [Tags]    csr-create    5_9_2
    Create Context Source With Invalid Content
    ...    csourceRegistrations/context-source-registration-invalid-structure-sample.jsonld

033_02_03_Create a context source registration with a date in the past
    [Tags]    csr-create    5_9_2
    Create Context Source With Invalid Content
    ...    csourceRegistrations/context-source-registration-past-expiration-sample.jsonld


*** Keywords ***
Create Context Source With Invalid Content
    [Documentation]    Check that you cannot create a context source with invalid content
    [Arguments]    ${filename}
    ${registration_id}=    Generate Random Entity Id    ${registration_id_prefix}
    ${payload}=    Load JSON From File    ${EXECDIR}/data/${filename}
    ${updated_payload}=    Update Value To JSON    ${payload}    $..id    ${registration_id}
    ${response}=    Create Context Source Registration With Return    ${updated_payload}
    Check Response Status Code    400    ${response.status_code}
    Check Response Headers Containing URI set to    ${registration_id}    ${response.headers}
    [Teardown]    Delete Context Source Registration    ${registration_id}

Create a context source registration with invalid JSON file
    [Documentation]    Create a context source registration with invalid JSON file
    [Tags]    csr-create
    ${registration_id}=    Generate Random Entity Id    ${registration_id_prefix}
    ${response}=    Create Context Source Registration
    ...    ${registration_payload_file_path}
    Check Response Status Code    <Response [400]>    ${response.status_code}
    Check Response Body Type When Using Session Request    ${response.json()}    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Title When Using Session Request    ${response.json()}
    [Teardown]    Delete Entity by Id Returning Response    ${registration_id}
