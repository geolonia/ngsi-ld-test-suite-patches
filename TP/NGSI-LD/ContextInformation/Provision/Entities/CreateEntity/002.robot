*** Settings ***
Documentation   Check that you cannot create an entity with an invalid request
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource

Test Template  Create Entity With Invalid Request Scenarios

*** Test Cases ***                        FILENAME                         
002_01_InvalidJson                        invalid-json-sample.jsonld            
002_02_EmptyJson                          empty-sample.jsonld
002_03_EntityWithNoContext                building-minimal-without-context-sample.jsonld      

*** Keywords ***
Create Entity With Invalid Request Scenarios
    [Arguments]  ${filename}
    [Documentation]  Check that you cannot create an entity with an invalid request
    [Tags]  mandatory

    Request Entity From File   ${filename}

    Check RL Response Status Code Set To Expected Code    400
    Check RL Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check RL Response Body Containing ProblemDetails Element Containing Title Element    ${response}