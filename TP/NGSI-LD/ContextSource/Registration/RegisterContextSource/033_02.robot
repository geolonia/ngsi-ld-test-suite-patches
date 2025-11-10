*** Settings ***
Documentation       Check that one cannot create a context source with invalid content

Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistration.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource
Library             OperatingSystem


*** Variables ***
${registration_payload_file_path}=      csourceRegistrations/context-source-registration-invalid.jsonld


*** Test Cases ***
033_02_01 Create A Context Source Registration With Invalid Content
    [Documentation]    Check that one cannot create a context source with invalid content
    [Tags]    csr-create    5_9_2
    ${csr_payload}=    Load JSON From File    ${EXECDIR}/data/${registration_payload_file_path}
    ${response}=    Create Context Source Registration
    ...    ${csr_payload}
    Check Response Status Code    400    ${response.status_code}
    Check Response Body Type When Using Session Request    ${response.json()}    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Title When Using Session Request    ${response.json()}
