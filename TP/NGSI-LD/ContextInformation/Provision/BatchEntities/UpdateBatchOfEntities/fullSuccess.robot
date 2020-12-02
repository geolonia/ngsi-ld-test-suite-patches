*** Settings ***
Documentation   Check that you can update a batch of entities
Variables   ../../../../../../resources/variables.py
Resource    ../../../../../../resources/ApiUtils.resource
Resource    ../../../../../../resources/AssertionUtils.resource
Resource    ../../../../../../resources/JsonUtils.resource
Library     REST    ${url}
Library     JSONLibrary
Library     String
Library     Collections

Suite Setup      Setup Initial Entities

*** Variable ***
${batch_endpoint}=    entityOperations/update
${endpoint}=    entities
${building_id_prefix}=  urn:ngsi-ld:Building:

*** Test Case ***
Update a batch of entities
    [Documentation]  Check that you can update a batch of entities
    [Tags]  critical

    ${first_entity}=    Load Entity    building-relationship-of-property-sample.jsonld      ${first_entity_id}
    ${second_entity}=    Load Entity    building-relationship-of-property-sample.jsonld      ${second_entity_id}
    @{entities_to_be_updated}=  Create List   ${first_entity}     ${second_entity}

    Batch Update Entities   @{entities_to_be_updated}

    Check Response Status Code Set To  204

    #TODO call Batch Delete Entities
    Delete Entity by Id  ${first_entity_id}
    Delete Entity by Id  ${second_entity_id}

*** Keywords ***
Setup Initial Entities
    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${second_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    Create Entity  building-simple-attributes-sample.jsonld     ${first_entity_id}
    Create Entity  building-simple-attributes-sample.jsonld     ${second_entity_id}

    Set Suite Variable  ${first_entity_id}
    Set Suite Variable  ${second_entity_id}
