*** Settings ***
Documentation   Check that you cannot delete a batch of entities with an invalid request
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource

*** Test Case ***
With invalid json document
    [Documentation]  Check that you cannot delete a batch of entities with an invalid json document
    [Tags]  mandatory

    Batch Request Entities From File   delete   filename=batch/invalid-json-sample.jsonld

    Check RL Response Status Code Set To  400
    Check RL Response Body Containing Problem Details Element Containing Detail Element    ${response}

With empty json document
    [Documentation]  Check that you cannot delete a batch of entities with an empty json document
    [Tags]  mandatory

    Batch Request Entities From File   delete   filename=batch/empty-sample.jsonld

    Check RL Response Status Code Set To  400
    Check RL Response Body Containing Problem Details Element Containing Detail Element    ${response}
