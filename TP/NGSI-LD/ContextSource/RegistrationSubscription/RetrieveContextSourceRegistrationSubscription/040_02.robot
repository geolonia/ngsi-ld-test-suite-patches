*** Settings ***
Documentation       Check that you cannot retrieve a context source registration subscription with an invalid URI, an error of type BadRequestData shall be raised

Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistrationSubscription.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource


*** Test Cases ***
040_02_01 Retrieve Context Source Registration Subscription With An Invalid Id
    [Documentation]    Check that you cannot retrieve a context source registration subscription with an invalid URI, an error of type BadRequestData shall be raised
    [Tags]    csrsub-retrieve    5_11_4
    ${response}=    Retrieve Context Source Registration Subscription
    ...    subscription_id=invalidUri
    Check Response Status Code    400    ${response.status_code}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()}
    ...    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}
