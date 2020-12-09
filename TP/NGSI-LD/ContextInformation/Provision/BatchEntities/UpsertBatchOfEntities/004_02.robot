*** Settings ***
Documentation   Check that you can upsert a batch of non-existing and existing entities where non-existing will be created and existing will be replaced
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Suite Setup      Setup Initial Entities
Test Template  Batch Upsert Non-existing And Existing Entities Scenarios
Suite Teardown      Delete Initial Entities

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:

*** Test Cases ***                        FILENAME
EntityWithSimpleProperties                building-simple-attributes-sample.jsonld
EntityWithSimpleRelationships             building-relationship-sample.jsonld
EntityWithRelationshipsProperties         building-relationship-of-property-sample.jsonld

*** Keywords ***
Batch Upsert Non-existing And Existing Entities Scenarios
    [Arguments]  ${filename}
    [Documentation]  Check that you can upsert a batch of non existing and existing entities
    [Tags]  mandatory

    ${new_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${new_entity}=    Load Entity    ${filename}      ${new_entity_id}
    ${first_existing_entity}=    Load Entity    ${filename}      ${first_existing_entity_id}
    ${second_existing_entity}=    Load Entity    ${filename}      ${second_existing_entity_id}
    @{entities_to_be_upserted}=  Create List   ${new_entity}     ${first_existing_entity}     ${second_existing_entity}

    Batch Upsert Entities   @{entities_to_be_upserted}

    @{expected_entities_ids}=  Create List   ${new_entity_id}
    Check Response Status Code Set To  201
    Check Response Body Containing Array Of URIs set to   @{expected_entities_ids}

    @{entities_ids_to_be_deleted}=  Create List   ${new_entity_id}
    Batch Delete Entities       @{entities_ids_to_be_deleted}

Setup Initial Entities
    ${first_existing_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${second_existing_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    Create Entity  building-minimal-sample.jsonld     ${first_existing_entity_id}
    Create Entity  building-minimal-sample.jsonld     ${second_existing_entity_id}

    Set Suite Variable  ${first_existing_entity_id}
    Set Suite Variable  ${second_existing_entity_id}

Delete Initial Entities
    @{entities_ids_to_be_deleted}=  Create List   ${first_existing_entity_id}      ${second_existing_entity_id}
    Batch Delete Entities       @{entities_ids_to_be_deleted}       teardown=True
