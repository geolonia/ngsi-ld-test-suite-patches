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
${entity_payload_filename}=  building-simple-attributes-sample.jsonld

*** Test Cases ***                        FILENAME                                              UPDATE_FRAGMENT_FILENAME
EntityWithSimpleProperties                building-simple-attributes-sample.jsonld              fragmentEntities/empty-fragment.json
EntityWithSimpleRelationships             building-relationship-sample.jsonld                   fragmentEntities/locatedAt-fragment.json
EntityWithRelationshipsProperties         building-relationship-of-property-sample.jsonld       fragmentEntities/empty-fragment.json

*** Keywords ***
Batch Update Entity With NoOverwrite Option Scenarios
    [Arguments]  ${filename}    ${update_fragment_filename}
    [Documentation]  Check that you can update a batch of entities with noOverwrite option
    [Tags]  mandatory

    ${first_entity}=    Load Entity    ${filename}      ${first_entity_id}
    ${second_entity}=    Load Entity    ${filename}      ${second_entity_id}
    @{entities_to_be_updated}=  Create List   ${first_entity}     ${second_entity}
    @{entities_ids_to_be_updated}=  Create List   ${first_entity_id}     ${second_entity_id}

    Batch Update Entities   @{entities_to_be_updated}       overwrite_option=noOverwrite

    Check Response Status Code Set To  204

    ${first_created_entity}=    Load Test Sample    entities/${entity_payload_filename}      ${first_entity_id}
    ${second_created_entity}=    Load Test Sample    entities/${entity_payload_filename}      ${second_entity_id}
    ${update_fragment}=    Load Test Sample    entities/${update_fragment_filename}
    ${first_updated_entity}=    Upsert Element In Entity     ${first_created_entity}    ${update_fragment}
    ${second_updated_entity}=    Upsert Element In Entity     ${second_created_entity}    ${update_fragment}
    @{updated_entities}=  Create List   ${first_updated_entity}     ${second_updated_entity}
    ${expected_entities_ids}=  Catenate    SEPARATOR=,     @{entities_ids_to_be_updated}
    Query Entities    ${expected_entities_ids}  Building    context=${ngsild_test_suite_context}    accept=${CONTENT_TYPE_LD_JSON}
    Check Updated Resources Set To   ${updated_entities}

Setup Initial Entities
    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${second_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    Create Entity  ${entity_payload_filename}     ${first_entity_id}
    Create Entity  ${entity_payload_filename}     ${second_entity_id}

    Set Suite Variable  ${first_entity_id}
    Set Suite Variable  ${second_entity_id}

Delete Initial Entities
    @{entities_ids_to_be_deleted}=  Create List   ${first_entity_id}     ${second_entity_id}
    Batch Delete Entities       @{entities_ids_to_be_deleted}       teardown=True
