*** Settings ***
Documentation   Check that you can upsert a batch of existing entities and they will be replaced
Variables   ${EXECDIR}/resources/variables.py
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource
Library     REST    ${url}
Library     JSONLibrary
Library     String
Library     Collections

Suite Setup      Setup Initial Entities

*** Variable ***
${batch_endpoint}=    entityOperations/upsert
${batch_delete_endpoint}=    entityOperations/delete
${endpoint}=    entities
${building_id_prefix}=  urn:ngsi-ld:Building:

*** Test Case ***
Upsert a batch of existing entities
    [Documentation]  Check that you can upsert a batch of existing entities
    [Tags]  critical

    ${first_existing_entity}=    Load Entity    building-minimal-sample.jsonld      ${first_existing_entity_id}
    ${second_existing_entity}=    Load Entity    building-minimal-sample.jsonld      ${second_existing_entity_id}
    @{entities_to_be_upserted}=  Create List   ${first_existing_entity}     ${second_existing_entity}

    Batch Upsert Entities   @{entities_to_be_upserted}

    Check Response Status Code Set To  204

    @{entities_ids_to_be_deleted}=  Create List   ${first_existing_entity_id}     ${second_existing_entity_id}
    Batch Delete Entities       @{entities_ids_to_be_deleted}

*** Keywords ***
Setup Initial Entities
    ${first_existing_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${second_existing_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    Create Entity  building-minimal-sample.jsonld     ${first_existing_entity_id}
    Create Entity  building-minimal-sample.jsonld     ${second_existing_entity_id}

    Set Suite Variable  ${first_existing_entity_id}
    Set Suite Variable  ${second_existing_entity_id}
