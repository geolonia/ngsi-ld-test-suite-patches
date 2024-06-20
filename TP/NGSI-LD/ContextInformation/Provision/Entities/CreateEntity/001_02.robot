*** Settings ***
Documentation       Check that one cannot create an entity with an invalid request

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource

Test Template       Create Entity With Invalid Request Scenarios


*** Test Cases ***    FILENAME    ERROR_TYPE
001_02_01 InvalidJson
    [Tags]    e-create    5_6_1
    invalid-json-sample.jsonld    ${ERROR_TYPE_INVALID_REQUEST}
001_02_02 EmptyJson
    [Tags]    e-create    5_6_1
    empty-sample.jsonld    ${ERROR_TYPE_INVALID_REQUEST}
001_02_03 EntityWithNoContext
    [Tags]    e-create    5_6_1
    building-minimal-sample.json    ${ERROR_TYPE_BAD_REQUEST_DATA}


*** Keywords ***
Create Entity With Invalid Request Scenarios
    [Documentation]    Check that one cannot create an entity with an invalid request
    [Arguments]    ${filename}    ${error_type}
    ${response}=    Create Entity From File    ${filename}
    Check Response Status Code    400    ${response.status_code}
    Check RL Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()}
    ...    ${error_type}
    Check RL Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}
