*** Settings ***
Documentation   Check that you cannot update a batch of entities with an invalid request
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource

Test Template  Batch Update Entity With Invalid Request Scenarios

*** Test Cases ***                        FILENAME                                  PROBLEM_TYPE
InvalidJson                               batch/invalid-json-sample.jsonld          ${ERROR_TYPE_INVALID_REQUEST}
InvalidJsonLd                             batch/invalid-json-ld-sample.jsonld       ${ERROR_TYPE_BAD_REQUEST_DATA}

*** Keywords ***
Batch Update Entity With Invalid Request Scenarios
    [Arguments]  ${filename}    ${problem_type}
    [Documentation]  Check that you cannot update a batch of entities with an invalid request
    [Tags]  mandatory

    Batch Request Entities From File   update   filename=${filename}

    Check RL Response Status Code Set To  400
    Check RL Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${problem_type}
    Check RL Response Body Containing ProblemDetails Element Containing Title Element    ${response}
