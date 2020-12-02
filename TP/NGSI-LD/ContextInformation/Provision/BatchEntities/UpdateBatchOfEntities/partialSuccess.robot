*** Settings ***
Documentation   Check that you can update a batch of entities where some will succeed and others will fail
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
Update a batch of non existing and existing entities
    [Documentation]  Check that you can update a batch of non existing and existing entities
    [Tags]  critical

    ${first_existing_entity}=    Load Entity    building-relationship-of-property-sample.jsonld      ${first_existing_entity_id}
    ${second_existing_entity}=    Load Entity    building-relationship-of-property-sample.jsonld      ${second_existing_entity_id}
    ${new_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${new_entity}=    Load Entity    building-relationship-of-property-sample.jsonld      ${new_entity_id}

    @{entities_to_be_updated}=  Create List   ${first_existing_entity}     ${second_existing_entity}    ${new_entity}

    Batch Update Entities   @{entities_to_be_updated}


    @{expected_successful_entities_ids}=  Create List   ${first_existing_entity_id}     ${second_existing_entity_id}
    @{expected_failed_entities_ids}=  Create List   ${new_entity_id}
    &{expected_batch_operation_result}=  Create Batch Operation Result   ${expected_successful_entities_ids}     ${expected_failed_entities_ids}
    Check Response Status Code Set To  207
    Check Response Body Containing Batch Operation Result   ${expected_batch_operation_result}

    #TODO call Batch Delete Entities
    Delete Entity by Id  ${first_existing_entity_id}
    Delete Entity by Id  ${second_existing_entity_id}

*** Keywords ***
Setup Initial Entities
    ${first_existing_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${second_existing_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    Create Entity  building-simple-attributes-sample.jsonld     ${first_existing_entity_id}
    Create Entity  building-simple-attributes-sample.jsonld     ${second_existing_entity_id}

    Set Suite Variable  ${first_existing_entity_id}
    Set Suite Variable  ${second_existing_entity_id}
