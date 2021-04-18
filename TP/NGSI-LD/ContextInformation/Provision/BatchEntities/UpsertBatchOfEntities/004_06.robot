*** Settings ***
Documentation     Check that you cannot upsert a batch of entities with an invalid request
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Test Template     Batch Upsert Entity With Invalid Request Scenarios

*** Test Cases ***    FILENAME                               PROBLEM_TYPE
InvalidJson           batch/invalid-json-sample.jsonld       ${ERROR_TYPE_INVALID_REQUEST}
                      [Tags]                                 be-upsert                         5_6_8

InvalidJsonLd         batch/invalid-json-ld-sample.jsonld    ${ERROR_TYPE_BAD_REQUEST_DATA}
                      [Tags]                                 be-upsert                         5_6_8

*** Keywords ***
Batch Upsert Entity With Invalid Request Scenarios
    [Arguments]    ${filename}    ${problem_type}
    [Documentation]    Check that you cannot upsert a batch of entities with an invalid request
    Batch Request Entities From File    upsert    filename=${filename}
    Check RL Response Status Code Set To    400
    Check RL Response Body Containing ProblemDetails Element Containing Type Element set to    ${response}    ${problem_type}
    Check RL Response Body Containing ProblemDetails Element Containing Title Element    ${response}
