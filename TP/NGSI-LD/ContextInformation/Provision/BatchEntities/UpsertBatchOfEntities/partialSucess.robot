*** Settings ***
Documentation   Check that you can upsert a batch of entities where some will succeed and others will fail
Variables   ${EXECDIR}/resources/variables.py
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource
Library     REST    ${url}
Library     JSONLibrary
Library     String
Library     Collections

*** Variable ***
${batch_endpoint}=    entityOperations/upsert
${batch_delete_endpoint}=    entityOperations/delete
${endpoint}=    entities
${building_id_prefix}=  urn:ngsi-ld:Building:

*** Test Case ***
Upsert a batch of two valid entities and one invalid entity
    [Documentation]  Check that you can upsert a batch of two valid entities and one invalid entity
    [Tags]  critical

    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${second_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${third_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${first_entity}=    Load Entity    building-minimal-sample.jsonld      ${first_entity_id}
    ${second_entity}=    Load Entity    building-minimal-sample.jsonld      ${second_entity_id}
    ${third_entity}=    Load Entity    building-minimal-sample.jsonld      ${third_entity_id}
    ${invalid_entity}=    Remove Entity Type       ${third_entity}

    @{entities_to_be_upserted}=  Create List   ${first_entity}     ${second_entity}     ${invalid_entity}

    Batch Upsert Entities   @{entities_to_be_upserted}

    @{expected_successful_entities_ids}=  Create List   ${first_entity_id}     ${second_entity_id}
    @{expected_failed_entities_ids}=  Create List   ${third_entity_id}
    &{expected_batch_operation_result}=  Create Batch Operation Result   ${expected_successful_entities_ids}     ${expected_failed_entities_ids}
    Check Response Status Code Set To  207
    Check Response Body Containing Batch Operation Result   ${expected_batch_operation_result}

    Batch Delete Entities       @{expected_successful_entities_ids}
