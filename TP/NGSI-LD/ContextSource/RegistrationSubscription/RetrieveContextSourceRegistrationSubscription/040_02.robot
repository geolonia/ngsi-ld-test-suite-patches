*** Settings ***
Documentation     Check that you cannot retrieve a context source registration subscription with an invalid URI, an error of type BadRequestData shall be raised
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource

*** Test Case ***
Retrieve Context Source Registration Subscription With An Invalid Id
    [Documentation]    Check that you cannot retrieve a context source registration subscription with an invalid URI, an error of type BadRequestData shall be raised
    [Tags]    csrsub-retrieve    5_11_4
    Retrieve Context Source Registration Subscription    invalidUri
    Check Response Status Code Set To    400
    Check Response Body Containing ProblemDetails Element Containing Type Element set to    ${response}    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}
