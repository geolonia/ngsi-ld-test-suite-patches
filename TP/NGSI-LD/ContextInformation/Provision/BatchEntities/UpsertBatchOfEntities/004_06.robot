*** Settings ***
Documentation   Check that you cannot upsert a batch of entities with an invalid request
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource

*** Test Case ***
With invalid json document
    [Documentation]  Check that you cannot upsert a batch of entities with an invalid json document
    [Tags]  mandatory

    Batch Request Entities From File   upsert   filename=batch/invalid-json-sample.jsonld

    Check RL Response Status Code Set To  400
    Check RL Response Body Containing Problem Details Element Containing Detail Element    ${response}

With json-ld document containing a null value in any of its items
    [Documentation]  Check that you cannot upsert a batch of entities with a json-ld document containing a null value in any of its items
    [Tags]  mandatory

    Batch Request Entities From File   upsert   filename=batch/invalid-json-ld-sample.jsonld

    Check RL Response Status Code Set To  400
    Check RL Response Body Containing Problem Details Element Containing Detail Element    ${response}
