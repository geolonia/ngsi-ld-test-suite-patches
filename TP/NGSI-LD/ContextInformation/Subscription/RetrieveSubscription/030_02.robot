*** Settings ***
Documentation   Check that you cannot retrieve a subscription: If the identifier provided does not correspond to any existing subscription in the system then an error of type ResourceNotFound shall be raised
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource

*** Test Case ***
Retrieve Unknown Subscription
    [Documentation]  Check that you cannot retrieve a subscription: If the identifier provided does not correspond to any existing subscription in the system then an error of type ResourceNotFound shall be raised
    [Tags]  mandatory

    Retrieve Subscription   unknownSubscription

    Check Response Status Code Set To  404
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_RESOURCE_NOT_FOUND}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}
