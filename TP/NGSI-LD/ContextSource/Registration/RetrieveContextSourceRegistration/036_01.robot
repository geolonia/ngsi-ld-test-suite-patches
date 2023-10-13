*** Settings ***
Documentation       Check that you cannot retrieve a Context Source Registration, if the context source registration id is not present or it is not a valid URI

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Template       Retrieve Context Source Registration With A Not Present Or Invalid Id


*** Test Cases ***    ID
036_01_01 Not Present Id    [Tags]    csr-retrieve    5_10_1
    ${EMPTY}
036_01_02 Invalid Id    [Tags]    csr-retrieve    5_10_1
    invalidUri


*** Keywords ***
Retrieve Context Source Registration With A Not Present Or Invalid Id
    [Documentation]    Check that you cannot retrieve a Context Source Registration, if the context source registration id is not present or it is not a valid URI
    [Arguments]    ${id}
    ${response}=    Retrieve Context Source Registration
    ...    context_source_registration_id=${id}
    Check Response Status Code    400    ${response.status_code}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()}
    ...    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}
