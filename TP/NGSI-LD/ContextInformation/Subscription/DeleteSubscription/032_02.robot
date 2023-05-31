*** Settings ***
Documentation       Check that you cannot delete a subscription: If the subscription id provided does not correspond to any existing subscription in the system then an error of type ResourceNotFound shall be raised

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource


*** Test Cases ***
Delete Unknown Subscription
    [Documentation]    Check that you cannot delete a subscription: If the subscription id provided does not correspond to any existing subscription in the system then an error of type ResourceNotFound shall be raised
    [Tags]    sub-delete    5_8_5
    Delete Subscription    urn:ngsi-ld:Subscription:unknowSubscription
    Check Response Status Code Set To    404
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response}
    ...    ${ERROR_TYPE_RESOURCE_NOT_FOUND}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}
