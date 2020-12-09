*** Settings ***
Documentation   Check that you can upsert a batch of entities with update option
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Suite Setup      Setup Initial Entities
Test Template  Batch Upsert Entities With Update Option Scenarios
Suite Teardown      Delete Initial Entities

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:

*** Test Cases ***                        FILENAME
EntityWithSimpleProperties                building-simple-attributes-sample.jsonld
EntityWithSimpleRelationships             building-relationship-sample.jsonld
EntityWithRelationshipsProperties         building-relationship-of-property-sample.jsonld

*** Keywords ***
Batch Upsert Entities With Update Option Scenarios
    [Arguments]  ${filename}
    [Documentation]  Check that you can upsert a batch of entities with update option
    [Tags]  mandatory

    ${new_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${new_entity}=    Load Entity    ${filename}      ${new_entity_id}
    ${existing_entity}=    Load Entity    ${filename}      ${existing_entity_id}
    @{entities_to_be_upserted}=  Create List   ${new_entity}     ${existing_entity}

    Batch Upsert Entities   @{entities_to_be_upserted}      update_option=update

    @{expected_entities_ids}=  Create List   ${new_entity_id}
    Check Response Status Code Set To  201
    Check Response Body Containing Array Of URIs set to   @{expected_entities_ids}

    @{entities_ids_to_be_deleted}=  Create List   ${new_entity_id}
    Batch Delete Entities       @{entities_ids_to_be_deleted}

Setup Initial Entities
    ${existing_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    Create Entity  building-minimal-sample.jsonld     ${existing_entity_id}

    Set Suite Variable  ${existing_entity_id}

Delete Initial Entities
    @{entities_ids_to_be_deleted}=  Create List   ${existing_entity_id}
    Batch Delete Entities       @{entities_ids_to_be_deleted}       teardown=True
