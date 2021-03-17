*** Settings ***
Documentation   Check that you cannot retrieve a subscription: If the subscription Id is not present or it is not a valid URI, then an error of type BadRequestData shall be raised
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource

Test Template  Retrieve Subscription With Non present Or Invalid Id

*** Test Cases ***          id
NotPresentId                ${EMPTY}
InvalidId                   InvalidUri

*** Keywords ***
Retrieve Subscription With Non present Or Invalid Id
    [Arguments]  ${id}
    [Documentation]  Check that you cannot retrieve a subscription: If the subscription Id is not present or it is not a valid URI, then an error of type BadRequestData shall be raised
    [Tags]  mandatory

    Retrieve Subscription   ${id}

    Check Response Status Code Set To  400
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}
