*** Settings ***
Documentation   Check that you cannot update a batch of entities with an invalid request
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource

*** Test Case ***
With invalid json document
    [Documentation]  Check that you cannot update a batch of entities with an invalid json document
    [Tags]  mandatory

    Batch Request Entities From File   update   filename=batch/invalid-json-sample.jsonld

    Check RL Response Status Code Set To  400
    Check RL Response Body Containing Problem Details Element Containing Detail Element    ${response}

With json-ld document not syntactically correct according to the @context
    [Documentation]  Check that you cannot update a batch of entities with a json-ld document not syntactically correct according to the @context
    [Tags]  mandatory

    #TODO: Use a json-ld document not syntactically correct according to the @context
    Batch Request Entities From File   update   filename=batch/invalid-json-ld-sample.jsonld

    Check RL Response Status Code Set To  400
    Check RL Response Body Containing Problem Details Element Containing Detail Element    ${response}
