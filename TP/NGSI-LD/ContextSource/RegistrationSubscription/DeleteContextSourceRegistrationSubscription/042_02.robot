*** Settings ***
Documentation     Check that you cannot delete a context source registration subscription with an invalid URI
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource

*** Test Case ***
Delete Context Source Registration Subscription With Invalid Uri
    [Documentation]    Check that you cannot delete a context source registration subscription with an invalid URI
    [Tags]    csrsub-delete    5_11_6
    Delete Context Source Registration Subscription    invalidUri
    Check Response Status Code Set To    400
    Check Response Body Containing ProblemDetails Element Containing Type Element set to    ${response}    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}
