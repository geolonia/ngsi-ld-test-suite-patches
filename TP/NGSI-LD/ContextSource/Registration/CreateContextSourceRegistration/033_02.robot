*** Settings ***
Documentation       Check that you cannot create a context source with invalid content

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Template       Create a context source registration with invalid JSON file


*** Variables ***
${registration_id_prefix}=              urn:ngsi-ld:Registration:
${registration_payload_file_path}=      context-source-registration-invalid-sample.jsonld


*** Test Cases ***
033_02_01 Create a context source registration with invalid JSON file
    Create a context source registration with invalid JSON file


*** Keywords ***
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
