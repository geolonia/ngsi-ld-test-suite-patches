*** Settings ***
Documentation   Check that you cannot upsert a batch of entities with an invalid request
Variables   ../../../../../../resources/variables.py
Resource    ../../../../../../resources/ApiUtils.resource
Resource    ../../../../../../resources/AssertionUtils.resource
Resource    ../../../../../../resources/JsonUtils.resource
Library     RequestsLibrary
Library     JSONLibrary
Library     OperatingSystem

*** Variable ***
${batch_endpoint}=    entityOperations/upsert
${endpoint}=    entities

*** Test Case ***
With invalid json document
    [Documentation]  Check that you cannot upsert a batch of entities with an invalid json document
    [Tags]  critical

    Batch Request Entities From File   building-invalid-sample.jsonld

    Check Response Status Code Set To  400
    Check Response Body Containing Problem Details Element Containing Detail Element    ${response}

With empty json document
    [Documentation]  Check that you cannot upsert a batch of entities with an empty json document
    [Tags]  critical

    Batch Request Entities From File   building-empty-sample.jsonld

    Check Response Status Code Set To  400
    Check Response Body Containing Problem Details Element Containing Detail Element    ${response}
