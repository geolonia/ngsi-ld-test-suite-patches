*** Settings ***
Documentation   Check that you can create a batch of entities where some will succeed and others will fail
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource
Library     JSONLibrary
Library     String
Library     Collections

Suite Setup      Setup Initial Entities

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:

*** Test Case ***
Create a batch of two valid entities and one invalid entity
    [Documentation]  Check that you can create a batch of two valid entities and one invalid entity
    [Tags]  mandatory

    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${second_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${first_entity}=    Load Entity    building-minimal-sample.jsonld      ${first_entity_id}
    ${second_entity}=    Load Entity    building-minimal-sample.jsonld      ${second_entity_id}
    ${already_existing_entity}=    Load Entity    building-minimal-sample.jsonld      ${existing_entity_id}
    @{entities_to_be_created}=  Create List   ${first_entity}     ${second_entity}     ${already_existing_entity}

    Batch Create Entities   @{entities_to_be_created}

    @{expected_successful_entities_ids}=  Create List   ${first_entity_id}     ${second_entity_id}
    @{expected_failed_entities_ids}=  Create List   ${existing_entity_id}
    &{expected_batch_operation_result}=  Create Batch Operation Result   ${expected_successful_entities_ids}     ${expected_failed_entities_ids}
    Check Response Status Code Set To  207
    Check Response Body Containing Batch Operation Result   ${expected_batch_operation_result}

    @{entities_ids_to_be_deleted}=  Create List   ${first_entity_id}     ${second_entity_id}    ${existing_entity_id}
    Batch Delete Entities       @{entities_ids_to_be_deleted}

*** Keywords ***
Setup Initial Entities
    ${existing_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    Create Entity  building-minimal-sample.jsonld     ${existing_entity_id}
    Set Suite Variable  ${existing_entity_id}
