*** Settings ***
Documentation   Check that you can update a batch of entities with noOverwrite option
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
${batch_delete_endpoint}=    entityOperations/delete
${endpoint}=    entities
${building_id_prefix}=  urn:ngsi-ld:Building:

*** Test Case ***
Update a batch of entities with noOverwrite option
    [Documentation]  Check that you can update a batch of entities with noOverwrite option
    [Tags]  critical

    ${first_entity}=    Load Entity    building-relationship-of-property-sample.jsonld      ${first_entity_id}
    ${second_entity}=    Load Entity    building-relationship-of-property-sample.jsonld      ${second_entity_id}
    @{entities_to_be_updated}=  Create List   ${first_entity}     ${second_entity}

    Batch Update Entities   @{entities_to_be_updated}       overwrite_option=noOverwrite

    Check Response Status Code Set To  204

    @{entities_ids_to_be_deleted}=  Create List   ${first_entity_id}     ${second_entity_id}
    Batch Delete Entities       @{entities_ids_to_be_deleted}

*** Keywords ***
Setup Initial Entities
    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${second_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    Create Entity  building-simple-attributes-sample.jsonld     ${first_entity_id}
    Create Entity  building-simple-attributes-sample.jsonld     ${second_entity_id}

    Set Suite Variable  ${first_entity_id}
    Set Suite Variable  ${second_entity_id}
