*** Settings ***
Documentation       Check that one gets an error when try to list @context with wrong details or kind

Resource            ${EXECDIR}/resources/ApiUtils/jsonldContext.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource

Test Template       List @contexts with no previous created @context


*** Variables ***
${filename}=        @context-minimal-valid.json
${reason_400}=      Bad Request
${reason_204}=      No Content


*** Test Cases ***    DETAILS    KIND
052_04_01 List @contexts with no details and kind set to other and not previously created @context
    [Tags]    ctx-list    5_13_3    since_v1.5.1
    ${EMPTY}    other
052_04_02 List @contexts with details set to other and no kind and not previously created @context
    [Tags]    ctx-list    5_13_3    since_v1.5.1
    other    ${EMPTY}
052_04_03 List @contexts with details set to other and kind set to other and not previously created @context
    [Tags]    ctx-list    5_13_3    since_v1.5.1
    other    other
052_04_04 List @contexts with details set to true and kind set to other and not previously created @context
    [Tags]    ctx-list    5_13_3    since_v1.5.1
    true    other
052_04_05 List @contexts with details set to other and kind set to Hosted and not previously created @context
    [Tags]    ctx-list    5_13_3    since_v1.5.1
    other    Hosted


*** Keywords ***
List @contexts with no previous created @context
    [Documentation]    Check that one can list @contexts
    [Arguments]    ${details}    ${kind}
    ${response}=    List @contexts    ${details}    ${kind}

    Check Response Status Code    400    ${response.status_code}
    Check Response Reason set to    ${response.reason}    ${reason_400}
    Check Response Body Containing ProblemDetails Element    ${response.json()}    ${ERROR_TYPE_BAD_REQUEST_DATA}
