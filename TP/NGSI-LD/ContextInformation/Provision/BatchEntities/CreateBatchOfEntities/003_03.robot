*** Settings ***
Documentation   Check that you cannot create a batch of entities with an invalid request
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource

Test Template  Create Batch Entity With Invalid Request Scenarios

*** Test Cases ***                        FILENAME
InvalidJson                               batch/invalid-json-sample.jsonld
EmptyJson                                 batch/empty-sample.jsonld

*** Keywords ***
Create Batch Entity With Invalid Request Scenarios
    [Arguments]  ${filename}
    [Documentation]  Check that you cannot create a batch of entities with an invalid request
    [Tags]  mandatory

    Batch Request Entities From File   create   filename=${filename}

    Check RL Response Status Code Set To  400
    Check RL Response Body Containing Problem Details Element Containing Detail Element    ${response}
