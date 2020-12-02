*** Settings ***
Documentation   Check that you cannot update a batch of entities with an invalid request
Variables   ../../../../../../resources/variables.py
Resource    ../../../../../../resources/ApiUtils.resource
Resource    ../../../../../../resources/AssertionUtils.resource
Resource    ../../../../../../resources/JsonUtils.resource
Library     RequestsLibrary
Library     JSONLibrary
Library     OperatingSystem

*** Variable ***
${batch_endpoint}=    entityOperations/update
${endpoint}=    entities

*** Test Case ***
With invalid json document
    [Documentation]  Check that you cannot update a batch of entities with an invalid json document
    [Tags]  critical

    Batch Request Entities From File   batch/invalid-json-sample.jsonld

    Check Response Status Code Set To  400
    Check Response Body Containing Problem Details Element Containing Detail Element    ${response}

With json-ld document not syntactically correct according to the @context
    [Documentation]  Check that you cannot update a batch of entities with a json-ld document not syntactically correct according to the @context
    [Tags]  critical

    #TODO: Use a json-ld document not syntactically correct according to the @context
    Batch Request Entities From File   batch/invalid-json-ld-sample.jsonld

    Check Response Status Code Set To  400
    Check Response Body Containing Problem Details Element Containing Detail Element    ${response}
