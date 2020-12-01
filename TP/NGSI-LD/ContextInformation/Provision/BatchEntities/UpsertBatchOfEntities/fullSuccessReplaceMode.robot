*** Settings ***
Documentation   Check that you can upsert a batch of entities
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
${batch_endpoint}=    entityOperations/upsert
${endpoint}=    entities
${building_id_prefix}=  urn:ngsi-ld:Building:

*** Test Case ***
Upsert a batch of non existing entities
    [Documentation]  Check that you can upsert a batch of non existing entities
    [Tags]  critical

    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${second_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${first_entity}=    Load Entity    building-minimal-sample.jsonld      ${first_entity_id}
    ${second_entity}=    Load Entity    building-minimal-sample.jsonld      ${second_entity_id}
    @{entities_to_be_upserted}=  Create List   ${first_entity}     ${second_entity}

    Batch Upsert Entities   @{entities_to_be_upserted}

    @{expected_entities_ids}=  Create List   ${first_entity_id}     ${second_entity_id}
    Check Response Status Code Set To  201
    Check Response Body Containing Array Of URIs set to   @{expected_entities_ids}

    #TODO call Batch Delete Entities
    Delete Entity by Id  ${first_entity_id}
    Delete Entity by Id  ${second_entity_id}

Upsert a batch of non existing and existing entities
    [Documentation]  Check that you can upsert a batch of non existing and existing entities
    [Tags]  critical

    ${new_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${new_entity}=    Load Entity    building-minimal-sample.jsonld      ${new_entity_id}
    ${first_existing_entity}=    Load Entity    building-minimal-sample.jsonld      ${first_existing_entity_id}
    ${second_existing_entity}=    Load Entity    building-minimal-sample.jsonld      ${second_existing_entity_id}
    @{entities_to_be_upserted}=  Create List   ${new_entity}     ${first_existing_entity}     ${second_existing_entity}

    Batch Upsert Entities   @{entities_to_be_upserted}

    @{expected_entities_ids}=  Create List   ${new_entity_id}
    Check Response Status Code Set To  201
    Check Response Body Containing Array Of URIs set to   @{expected_entities_ids}

    #TODO call Batch Delete Entities
    Delete Entity by Id  ${new_entity_id}
    Delete Entity by Id  ${first_existing_entity_id}
    Delete Entity by Id  ${second_existing_entity_id}

*** Keywords ***
Setup Initial Entities
    ${first_existing_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${second_existing_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    Create Entity  building-minimal-sample.jsonld     ${first_existing_entity_id}
    Create Entity  building-minimal-sample.jsonld     ${second_existing_entity_id}

    Set Suite Variable  ${first_existing_entity_id}
    Set Suite Variable  ${second_existing_entity_id}
