*** Settings ***
Documentation   Check that you cannot delete a batch of entities with an invalid request
Variables   ${EXECDIR}/resources/variables.py
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Library     RequestsLibrary
Library     JSONLibrary
Library     OperatingSystem


*** Variable ***
${batch_endpoint}=    entityOperations/delete
${endpoint}=    entities

*** Test Case ***
With invalid json document
    [Documentation]  Check that you cannot delete a batch of entities with an invalid json document
    [Tags]  critical

    Batch Request Entities From File   batch/invalid-json-sample.jsonld

    Check RL Response Status Code Set To  400
    Check RL Response Body Containing Problem Details Element Containing Detail Element    ${response}

With empty json document
    [Documentation]  Check that you cannot delete a batch of entities with an empty json document
    [Tags]  critical

    Batch Request Entities From File   batch/empty-sample.jsonld

    Check RL Response Status Code Set To  400
    Check RL Response Body Containing Problem Details Element Containing Detail Element    ${response}
