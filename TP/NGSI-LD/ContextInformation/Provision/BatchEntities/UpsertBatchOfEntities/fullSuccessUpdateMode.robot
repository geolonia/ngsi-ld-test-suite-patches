*** Settings ***
Documentation   Check that you can upsert a batch of entities with update option
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
Upsert a batch of entities with update option
    [Documentation]  Check that you can upsert a batch of entities with update option
    [Tags]  critical

    ${new_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${new_entity}=    Load Entity    building-minimal-sample.jsonld      ${new_entity_id}
    ${existing_entity}=    Load Entity    building-minimal-sample.jsonld      ${existing_entity_id}
    @{entities_to_be_upserted}=  Create List   ${new_entity}     ${existing_entity}

    Batch Upsert Entities   @{entities_to_be_upserted}      update_option=update

    @{expected_entities_ids}=  Create List   ${new_entity_id}
    Check Response Status Code Set To  201
    Check Response Body Containing Array Of URIs set to   @{expected_entities_ids}

    @{entities_ids_to_be_deleted}=  Create List   ${new_entity_id}     ${existing_entity_id}
    Batch Delete Entities       @{entities_ids_to_be_deleted}

*** Keywords ***
Setup Initial Entities
    ${existing_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    Create Entity  building-minimal-sample.jsonld     ${existing_entity_id}

    Set Suite Variable  ${existing_entity_id}
