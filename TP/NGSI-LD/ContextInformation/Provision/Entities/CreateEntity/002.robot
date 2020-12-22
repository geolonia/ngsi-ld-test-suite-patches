*** Settings ***
Documentation   Check that you cannot create an entity with an invalid request
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource

Test Template  Create Entity With Invalid Request Scenarios

*** Test Cases ***                        FILENAME                              PROBLEM_TYPE                        EXPECTED_CODE
InvalidJson                               invalid-json-sample.jsonld            ${ERROR_TYPE_INVALID_REQUEST}       406
EmptyJson                                 empty-sample.jsonld                   ${ERROR_TYPE_BAD_REQUEST_DATA}      400

*** Keywords ***
Create Entity With Invalid Request Scenarios
    [Arguments]  ${filename}    ${problem_type}    ${expected_code}
    [Documentation]  Check that you cannot create an entity with an invalid request
    [Tags]  mandatory

    Request Entity From File   ${filename}

    Check RL Response Status Code Set To Expected Code    ${expected_code}
    Check RL Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${problem_type}
    Check RL Response Body Containing ProblemDetails Element Containing Title Element    ${response}