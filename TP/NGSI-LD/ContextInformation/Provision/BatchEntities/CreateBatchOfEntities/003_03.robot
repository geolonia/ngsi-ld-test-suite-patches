*** Settings ***
Documentation       Check that you cannot create a batch of entities with an invalid request

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource

Test Template       Create Batch Entity With Invalid Request Scenarios


*** Test Cases ***    FILENAME    PROBLEM_TYPE
InvalidJson    [Tags]    be-create    5_6_7
    batch/invalid-json-sample.jsonld    ${ERROR_TYPE_INVALID_REQUEST}
EmptyJson    [Tags]    be-create    5_6_7
    batch/empty-sample.jsonld    ${ERROR_TYPE_BAD_REQUEST_DATA}


*** Keywords ***
Create Batch Entity With Invalid Request Scenarios
    [Documentation]    Check that you cannot create a batch of entities with an invalid request
    [Arguments]    ${filename}    ${problem_type}
    Batch Request Entities From File    create    filename=${filename}
    Check RL Response Status Code Set To    400
    Check RL Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response}
    ...    ${problem_type}
    Check RL Response Body Containing ProblemDetails Element Containing Title Element    ${response}
