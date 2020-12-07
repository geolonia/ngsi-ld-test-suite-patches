*** Settings ***
Documentation   Check that you can delete a batch of entities where some will succeed and others will fail
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
${batch_delete_endpoint}=    entityOperations/delete
${endpoint}=    entities
${building_id_prefix}=  urn:ngsi-ld:Building:

*** Test Case ***
Delete a batch of non existing and existing entities
    [Documentation]  Check that you can delete a batch of non existing and existing entities
    [Tags]  critical

    ${new_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    @{entities_ids_to_be_deleted}=  Create List   ${existing_entity_id}     ${new_entity_id}

    Batch Delete Entities   @{entities_ids_to_be_deleted}

    @{expected_successful_entities_ids}=  Create List   ${existing_entity_id}
    @{expected_failed_entities_ids}=  Create List   ${new_entity_id}
    &{expected_batch_operation_result}=  Create Batch Operation Result   ${expected_successful_entities_ids}     ${expected_failed_entities_ids}
    Check Response Status Code Set To  207
    Check Response Body Containing Batch Operation Result   ${expected_batch_operation_result}


*** Keywords ***
Setup Initial Entities
    ${existing_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    Create Entity  building-simple-attributes-sample.jsonld     ${existing_entity_id}

    Set Suite Variable  ${existing_entity_id}
