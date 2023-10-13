*** Settings ***
Documentation       Check that you cannot delete a context source registration under some conditions

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Teardown       Delete Created Context Source Registrations
Test Template       Delete Context Source


*** Variables ***
${registration_id_prefix}=      urn:ngsi-ld:Registration:
${filename}=                    context-source-registration-simple-sample.jsonld


*** Test Cases ***    INVALID_REGISTRATION_ID
035_02_01 Delete a Context Source Registration if the Id is not present
    ${EMPTY}
035_02_02 Delete a Context Source Registration if the Id is not a valid URI
    invalidURI


*** Keywords ***
Delete Context Source
    [Documentation]    Check that you cannot delete a context source registration under some conditions
    [Tags]    csr-delete    5_9_4
    [Arguments]    ${invalid_registration_id}
    ${registration_id}=    Generate Random Entity Id    ${registration_id_prefix}
    Set Test Variable    ${registration_id}
    ${payload}=    Load JSON From File    ${EXECDIR}/data/csourceRegistrations/${filename}
    ${updated_payload}=    Update Value To JSON    ${payload}    $..id    ${registration_id}
    ${response}=    Create Context Source Registration With Return    ${updated_payload}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Delete Context Source Registration With Return    ${invalid_registration_id}
    Check Response Status Code    400    ${response.status_code}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}
    [Teardown]    Delete Context Source Registration    ${registration_id}

Delete Created Context Source Registrations
    Delete Context Source Registration    ${registration_id}
