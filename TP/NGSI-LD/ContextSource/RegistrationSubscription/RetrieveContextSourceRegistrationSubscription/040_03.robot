*** Settings ***
Documentation       Check that you cannot retrieve an unknown context source registration subscription, an error of type ResourceNotFound shall be raised

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource


*** Test Cases ***
040_03_01 Retrieve Unknown Context Source Registration Subscription
    [Documentation]    Check that you cannot retrieve an unknown context source registration subscription, an error of type ResourceNotFound shall be raised
    [Tags]    csrsub-retrieve    5_11_4
    ${response}=    Retrieve Context Source Registration Subscription
    ...    subscription_id=urn:ngsi-ld:Subscription:unknowSubscription
    Check Response Status Code    404    ${response.status_code}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()}
    ...    ${ERROR_TYPE_RESOURCE_NOT_FOUND}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}
