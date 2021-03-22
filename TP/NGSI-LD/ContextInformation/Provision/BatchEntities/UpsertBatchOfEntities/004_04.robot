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
${existing_entity_payload_filename}=  building-minimal-sample.jsonld

*** Test Cases ***                        FILENAME                                          UPDATE_FRAGMENT_FILENAME
EntityWithSimpleProperties                building-simple-attributes-sample.jsonld          fragmentEntities/simple-attributes-fragment.json
EntityWithSimpleRelationships             building-relationship-sample.jsonld               fragmentEntities/locatedAt-fragment.json
EntityWithRelationshipsProperties         building-relationship-of-property-sample.jsonld   fragmentEntities/simple-attributes-relationship-of-property-fragment.json

*** Keywords ***
Batch Upsert Entities With Update Option Scenarios
    [Arguments]  ${filename}    ${update_fragment_filename}
    [Documentation]  Check that you can upsert a batch of entities with update option
    [Tags]  mandatory

    ${new_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${new_entity}=    Load Entity    ${filename}      ${new_entity_id}
    ${existing_entity}=    Load Entity    ${filename}      ${existing_entity_id}
    @{entities_to_be_upserted}=  Create List   ${new_entity}     ${existing_entity}
    @{entities_ids_to_be_upserted}=  Create List   ${existing_entity_id}     ${new_entity_id}

    Batch Upsert Entities   @{entities_to_be_upserted}      update_option=update

    @{expected_entities_ids}=  Create List   ${new_entity_id}
    Check Response Status Code Set To  201
    Check Response Body Containing Array Of URIs set to   @{expected_entities_ids}

    ${old_entity}=    Load Test Sample    entities/${existing_entity_payload_filename}      ${existing_entity_id}
    ${update_fragment}=    Load Test Sample    entities/${update_fragment_filename}
    ${old_updated_entity}=    Upsert Element In Entity     ${old_entity}    ${update_fragment}
    @{updated_entities}=  Create List   ${new_entity}     ${old_updated_entity}
    ${expected_updated_entities_ids}=  Catenate    SEPARATOR=,     @{entities_ids_to_be_upserted}
    Query Entities    ${expected_updated_entities_ids}  Building    context=${ngsild_test_suite_context}
    ${ignored_keys}=    Create List     ${context_regex_expr}
    Check Updated Resources Set To   ${updated_entities}    ${ignored_keys}

    @{entities_ids_to_be_deleted}=  Create List   ${new_entity_id}
    Batch Delete Entities       @{entities_ids_to_be_deleted}

Setup Initial Entities
    ${existing_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    Create Entity  ${existing_entity_payload_filename}     ${existing_entity_id}

    Set Suite Variable  ${existing_entity_id}

Delete Initial Entities
    @{entities_ids_to_be_deleted}=  Create List   ${existing_entity_id}
    Batch Delete Entities       @{entities_ids_to_be_deleted}       teardown=True
