*** Settings ***
Documentation       Check that you cannot delete a context source registration under some conditions

Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistration.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Create Initial Context Source Registration
Test Teardown       Delete Created Context Source Registrations
Test Template       Delete A Context Source


*** Variables ***
${registration_id_prefix}=      urn:ngsi-ld:Registration:
${filename}=                    context-source-registration-sample.jsonld


*** Test Cases ***    INVALID_REGISTRATION_ID    EXPECTED_STATUS_CODE
035_02_01 Delete a Context Source Registration if the Id is not present
    [Tags]    csr-delete    5_9_4
    ${EMPTY}    405
035_02_02 Delete a Context Source Registration if the Id is not a valid URI
    [Tags]    csr-delete    5_9_4
    invalidURI    400


*** Keywords ***
Delete A Context Source
    [Documentation]    Check that you cannot delete a context source registration under some conditions
    [Arguments]    ${invalid_registration_id}    ${expected_status_code}
    ${response}=    Delete Context Source Registration With Return    ${invalid_registration_id}
    Check Response Status Code    ${expected_status_code}    ${response.status_code}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}

Delete Created Context Source Registrations
    Delete Context Source Registration    ${registration_id}

Create Initial Context Source Registration
    ${registration_id}=    Generate Random Entity Id    ${registration_id_prefix}
    Set Test Variable    ${registration_id}
    ${payload}=    Load JSON From File    ${EXECDIR}/data/csourceRegistrations/${filename}
    ${updated_payload}=    Update Value To JSON    ${payload}    $..id    ${registration_id}
    ${response}=    Create Context Source Registration With Return    ${updated_payload}
    Check Response Status Code    201    ${response.status_code}
