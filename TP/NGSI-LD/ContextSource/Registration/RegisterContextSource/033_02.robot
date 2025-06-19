*** Settings ***
Documentation       Check that one cannot create a context source with invalid content

Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistration.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource
Library             OperatingSystem


*** Variables ***
${registration_payload_file_path}=      csourceRegistrations/context-source-registration-invalid.jsonld


*** Test Cases ***
033_02_01 Create a context source registration with invalid JSON file
    [Documentation]    Create a context source registration with invalid JSON file
    [Tags]    csr-create    5_9_2
    ${subscription_payload}=    Get File    ${EXECDIR}/data/${registration_payload_file_path}
    ${response}=    Create Context Source Registration
    ...    ${subscription_payload}
    Check Response Status Code    400    ${response.status_code}
    Check Response Body Type When Using Session Request    ${response.json()}    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Title When Using Session Request    ${response.json()}
