*** Settings ***
Documentation       Check that you cannot create a context source with invalid content

Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistration.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Template       Create Context Source With Invalid Content


*** Variables ***
${registration_id_prefix}=      urn:ngsi-ld:Registration:


*** Test Cases ***
033_10_01 Create a context source registration with a different data structure than CSourceRegistration data type
    csourceRegistrations/context-source-registration-invalid-structure-sample.jsonld
033_10_02 Create a context source registration with a date in the past
    csourceRegistrations/context-source-registration-past-expiration-sample.jsonld


*** Keywords ***
Create Context Source With Invalid Content
    [Documentation]    Check that you cannot create a context source with invalid content
    [Tags]    csr-create    6_3_5
    [Arguments]    ${filename}
    ${registration_id}=    Generate Random Entity Id    ${registration_id_prefix}
    ${payload}=    Load JSON From File    ${EXECDIR}/data/${filename}
    ${updated_payload}=    Update Value To JSON    ${payload}    $..id    ${registration_id}
    ${response}=    Create Context Source Registration With Return    ${updated_payload}
    Check Response Status Code    400    ${response.status_code}
    Check Response Headers Containing URI set to    ${registration_id}    ${response.headers}
