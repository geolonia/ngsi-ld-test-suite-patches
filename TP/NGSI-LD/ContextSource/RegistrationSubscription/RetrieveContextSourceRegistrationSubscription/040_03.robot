*** Settings ***
Documentation     Check that you cannot retrieve an unknown context source registration subscription, an error of type ResourceNotFound shall be raised
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource

*** Test Case ***
Retrieve Unknown Context Source Registration Subscription
    [Documentation]    Check that you cannot retrieve an unknown context source registration subscription, an error of type ResourceNotFound shall be raised
    [Tags]    csrsub-retrieve    5_11_4
    Retrieve Context Source Registration Subscription    urn:ngsi-ld:Subscription:unknowSubscription
    Check Response Status Code Set To    404
    Check Response Body Containing ProblemDetails Element Containing Type Element set to    ${response}    ${ERROR_TYPE_RESOURCE_NOT_FOUND}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}
