*** Settings ***
Documentation     Check that you cannot create a subscription with an invalid request
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Test Template     Create Subscription With Invalid Request

*** Test Cases ***    FILENAME
031_02_01_InvalidJson
                      subscription-invalid-json-sample.jsonld

031_02_02_EmptyJson
                      subscription-empty-sample.jsonld

*** Keywords ***
Create Subscription With Invalid Request
    [Arguments]    ${filename}
    [Documentation]    Check that you cannot create a subscription with an invalid request
    [Tags]    sub-create    5_8_1
    Create Subscription From File    ${filename}
    Check RL Response Status Code Set To Expected Code    400
    Check RL Response Body Containing ProblemDetails Element Containing Type Element set to    ${response}    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check RL Response Body Containing ProblemDetails Element Containing Title Element    ${response}
