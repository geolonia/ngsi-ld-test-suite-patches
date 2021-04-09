*** Settings ***
Documentation   Check that you cannot query context source registration subscriptions with invalid page and limit parameters
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Query Context Source Registration Subscriptions With Invalid Limit And Page Parameters

*** Test Cases ***                        LIMIT         PAGE
Invalid Limit                             ${-5}         ${2}
    [Tags]   csrsub-query    5_11_5
Invalid Page                              ${2}          ${-3}
    [Tags]   csrsub-query    5_11_5
Invalid Limit And Page                    ${0}          ${0}
    [Tags]   csrsub-query    5_11_5

*** Keywords ***
Query Context Source Registration Subscriptions With Invalid Limit And Page Parameters
    [Arguments]  ${limit}     ${page}
    [Documentation]  Check that you cannot query context source registration subscriptions with invalid page and limit parameters

    Query Context Source Registration Subscriptions  limit=${limit}      page=${page}

    Check Response Status Code Set To  400
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}
