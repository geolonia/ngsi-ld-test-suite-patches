*** Settings ***
Documentation       Check that you cannot merge a batch of entities with an invalid request

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource

Test Template       Batch Merge Entity With Invalid Request Scenarios


*** Test Cases ***    FILENAME    PROBLEM_TYPE
057_03_01 InvalidJson    [Tags]    be-merge    5_6_17    since_v1.6.1
    batch/invalid-json.jsonld    ${ERROR_TYPE_INVALID_REQUEST}
057_03_02 InvalidJsonLd    [Tags]    be-merge    5_6_17    since_v1.6.1
    batch/invalid-json-ld.jsonld    ${ERROR_TYPE_BAD_REQUEST_DATA}


*** Keywords ***
Batch Merge Entity With Invalid Request Scenarios
    [Documentation]    Check that you cannot merge a batch of entities with an invalid request
    [Arguments]    ${filename}    ${problem_type}
    ${response}=    Batch Request Entities From File    merge    filename=${filename}
    Check Response Status Code    400    ${response.status_code}
    Check RL Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()}
    ...    ${problem_type}
    Check RL Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}
