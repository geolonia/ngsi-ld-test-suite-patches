*** Settings ***
Documentation   Check that you can update a batch of entities with noOverwrite option
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Suite Setup      Setup Initial Entities
Test Template  Batch Update Entity With NoOverwrite Option Scenarios
Suite Teardown      Delete Initial Entities

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:

*** Test Cases ***                        FILENAME
EntityWithSimpleProperties                building-simple-attributes-sample.jsonld
EntityWithSimpleRelationships             building-relationship-sample.jsonld
EntityWithRelationshipsProperties         building-relationship-of-property-sample.jsonld

*** Keywords ***
Batch Update Entity With NoOverwrite Option Scenarios
    [Arguments]  ${filename}
    [Documentation]  Check that you can update a batch of entities with noOverwrite option
    [Tags]  mandatory

    ${first_entity}=    Load Entity    ${filename}      ${first_entity_id}
    ${second_entity}=    Load Entity    ${filename}      ${second_entity_id}
    @{entities_to_be_updated}=  Create List   ${first_entity}     ${second_entity}

    Batch Update Entities   @{entities_to_be_updated}       overwrite_option=noOverwrite

    Check Response Status Code Set To  204

Setup Initial Entities
    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${second_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    Create Entity  building-simple-attributes-sample.jsonld     ${first_entity_id}
    Create Entity  building-simple-attributes-sample.jsonld     ${second_entity_id}

    Set Suite Variable  ${first_entity_id}
    Set Suite Variable  ${second_entity_id}

Delete Initial Entities
    @{entities_ids_to_be_deleted}=  Create List   ${first_entity_id}     ${second_entity_id}
    Batch Delete Entities       @{entities_ids_to_be_deleted}       teardown=True
