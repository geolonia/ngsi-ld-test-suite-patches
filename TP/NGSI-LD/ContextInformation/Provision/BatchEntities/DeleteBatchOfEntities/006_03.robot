*** Settings ***
Documentation       Check that you cannot delete a batch of entities with an invalid request

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource

Test Template       Batch Delete Entity With Invalid Request Scenarios


*** Test Cases ***    FILENAME    PROBLEM_TYPE
InvalidJson    [Tags]    be-delete    5_6_10
    batch/invalid-json-sample.jsonld    ${ERROR_TYPE_INVALID_REQUEST}
EmptyJson    [Tags]    be-delete    5_6_10
    batch/empty-sample.jsonld    ${ERROR_TYPE_BAD_REQUEST_DATA}


*** Keywords ***
Batch Delete Entity With Invalid Request Scenarios
    [Documentation]    Check that you cannot delete a batch of entities with an invalid request
    [Arguments]    ${filename}    ${problem_type}
    Batch Request Entities From File    delete    filename=${filename}
    Check RL Response Status Code Set To    400
    Check RL Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response}
    ...    ${problem_type}
    Check RL Response Body Containing ProblemDetails Element Containing Title Element    ${response}
