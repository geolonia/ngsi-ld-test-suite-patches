*** Settings ***
Documentation       Check that you cannot update a batch of entities with an invalid request

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource

Test Template       Batch Update Entity With Invalid Request Scenarios


*** Test Cases ***    FILENAME    PROBLEM_TYPE
005_04_01 InvalidJson
    [Tags]    be-update    5_6_9
    batch/invalid-json-sample.jsonld    ${ERROR_TYPE_INVALID_REQUEST}
005_04_02 InvalidJsonLd
    [Tags]    be-update    5_6_9
    batch/invalid-json-ld-sample.jsonld    ${ERROR_TYPE_BAD_REQUEST_DATA}


*** Keywords ***
Batch Update Entity With Invalid Request Scenarios
    [Documentation]    Check that you cannot update a batch of entities with an invalid request
    [Arguments]    ${filename}    ${problem_type}
    ${response}=    Batch Request Entities From File    update    filename=${filename}
    Check Response Status Code    400    ${response.status_code}
    Check RL Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()}
    ...    ${problem_type}
    Check RL Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}
