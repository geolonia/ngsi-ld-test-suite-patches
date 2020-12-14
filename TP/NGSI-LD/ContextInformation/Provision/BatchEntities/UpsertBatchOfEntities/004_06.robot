*** Settings ***
Documentation   Check that you cannot upsert a batch of entities with an invalid request
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource

Test Template  Batch Upsert Entity With Invalid Request Scenarios

*** Test Cases ***                        FILENAME
InvalidJson                               batch/invalid-json-sample.jsonld
InvalidJsonLd                             batch/invalid-json-ld-sample.jsonld

*** Keywords ***
Batch Upsert Entity With Invalid Request Scenarios
    [Arguments]  ${filename}
    [Documentation]  Check that you cannot upsert a batch of entities with an invalid request
    [Tags]  mandatory

    Batch Request Entities From File   upsert   filename=${filename}

    Check RL Response Status Code Set To  400
    Check RL Response Body Containing ProblemDetails Element Containing Detail Element    ${response}
