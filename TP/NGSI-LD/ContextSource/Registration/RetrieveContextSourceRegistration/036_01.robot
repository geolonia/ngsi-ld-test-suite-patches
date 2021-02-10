*** Settings ***
Documentation   Check that you cannot a retrieve Context Source Registration, if the context source registration id is not present or it is not a valid URI
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Retrieve Context Source Registration With A Not Present Or Invalid Id

*** Test Cases ***                       ID
Not Present Id                           ${EMPTY}
Invalid Id                               invalidUri

*** Keywords ***

Retrieve Context Source Registration With A Not Present Or Invalid Id
    [Arguments]  ${id}

    [Documentation]  Check that you cannot a retrieve Context Source Registration, if the context source registration id is not present or it is not a valid URI
    [Tags]  mandatory

    Retrieve Context Source Registration  ${id}

    Check Response Status Code Set To  400
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}
