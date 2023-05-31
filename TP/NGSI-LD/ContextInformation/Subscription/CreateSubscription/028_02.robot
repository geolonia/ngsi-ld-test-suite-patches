*** Settings ***
Documentation       Check that you cannot create a subscription with an invalid request

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource

Test Template       Create Subscription With Invalid Request


*** Test Cases ***    FILENAME    EXPECTED_STATUS
028_02_01_InvalidJson
    subscription-invalid-json-sample.jsonld    ${ERROR_TYPE_INVALID_REQUEST}
028_02_02_EmptyJson
    subscription-empty-sample.jsonld    ${ERROR_TYPE_BAD_REQUEST_DATA}


*** Keywords ***
Create Subscription With Invalid Request
    [Documentation]    Check that you cannot create a subscription with an invalid request
    [Tags]    sub-create    5_8_1
    [Arguments]    ${filename}    ${expected_status}
    Create Subscription From File    ${filename}
    Check RL Response Status Code Set To    400
    Check RL Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response}
    ...    ${expected_status}
    Check RL Response Body Containing ProblemDetails Element Containing Title Element    ${response}
