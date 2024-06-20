*** Settings ***
Documentation       Check that one cannot query context source registration subscriptions with invalid page and limit parameters

Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistrationSubscription.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Template       Query Context Source Registration Subscriptions With Invalid Limit And Page Parameters


*** Test Cases ***    LIMIT    PAGE
041_04_01 Invalid Limit
    [Tags]    csrsub-query    5_11_5
    ${-5}    ${2}
041_04_02 Invalid Page
    [Tags]    csrsub-query    5_11_5
    ${2}    ${-3}
041_04_03 Invalid Limit And Page
    [Tags]    csrsub-query    5_11_5
    ${0}    ${0}


*** Keywords ***
Query Context Source Registration Subscriptions With Invalid Limit And Page Parameters
    [Documentation]    Check that one cannot query context source registration subscriptions with invalid page and limit parameters
    [Arguments]    ${limit}    ${page}
    ${response}=    Query Context Source Registration Subscriptions    limit=${limit}    page=${page}
    Check Response Status Code    400    ${response.status_code}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()}
    ...    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}
