*** Settings ***
Documentation   Check that you cannot delete an unknown context source registration subscription
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Test Case ***
Delete Unknown Context Source Registration Subscription With Invalid Uri
    [Documentation]  Check that you cannot delete an unknown context source registration subscription
    [Tags]  mandatory

    Delete Context Source Registration Subscription  urn:ngsi-ld:Subscription:unknowSubscription

    Check Response Status Code Set To  404
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_RESOURCE_NOT_FOUND}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}
