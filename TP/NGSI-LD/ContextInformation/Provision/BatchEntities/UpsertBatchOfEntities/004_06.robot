*** Settings ***
Documentation       Check that one cannot upsert a batch of entities with an invalid request

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource

Test Template       Batch Upsert Entity With Invalid Request Scenarios


*** Test Cases ***    FILENAME    PROBLEM_TYPE
004_06_01 InvalidJson
    [Tags]    be-upsert    5_6_8
    batch/invalid-json.jsonld    ${ERROR_TYPE_INVALID_REQUEST}
004_06_02 InvalidJsonLd
    [Tags]    be-upsert    5_6_8
    batch/invalid-json-ld.jsonld    ${ERROR_TYPE_BAD_REQUEST_DATA}


*** Keywords ***
Batch Upsert Entity With Invalid Request Scenarios
    [Documentation]    Check that one cannot upsert a batch of entities with an invalid request
    [Arguments]    ${filename}    ${problem_type}
    ${response}=    Batch Request Entities From File    upsert    filename=${filename}
    Check Response Status Code    400    ${response.status_code}
    Check RL Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()['errors'][0]['error']}
    ...    ${problem_type}
    Check RL Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()['errors'][0]['error']}
