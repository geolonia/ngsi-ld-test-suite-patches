*** Settings ***
Documentation       Check that you can upsert a batch of existing entities and they will be replaced

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Setup Initial Entities
Test Teardown       Delete Initial Entities
Test Template       Batch Upsert Existing Entities Scenarios


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:


*** Test Cases ***    FILENAME
EntityWithSimpleProperties
    [Tags]    be-upsert    5_6_8
    building-simple-attributes-sample.jsonld
EntityWithSimpleRelationships
    [Tags]    be-upsert    5_6_8
    building-relationship-sample.jsonld
EntityWithRelationshipsProperties
    [Tags]    be-upsert    5_6_8
    building-relationship-of-property-sample.jsonld


*** Keywords ***
Batch Upsert Existing Entities Scenarios
    [Documentation]    Check that you can upsert a batch of existing entities
    [Arguments]    ${filename}
    ${first_existing_entity}=    Load Entity    ${filename}    ${first_existing_entity_id}
    ${second_existing_entity}=    Load Entity    ${filename}    ${second_existing_entity_id}
    @{entities_to_be_upserted}=    Create List    ${first_existing_entity}    ${second_existing_entity}
    Batch Upsert Entities    @{entities_to_be_upserted}
    Check Response Status Code Set To    204
    @{upserted_entities_ids}=    Create List    ${first_existing_entity_id}    ${second_existing_entity_id}
    ${expected_updated_entities_ids}=    Catenate    SEPARATOR=,    @{upserted_entities_ids}
    Query Entities
    ...    ${expected_updated_entities_ids}
    ...    Building
    ...    context=${ngsild_test_suite_context}
    ...    accept=${CONTENT_TYPE_LD_JSON}
    Check Updated Resources Set To    ${entities_to_be_upserted}

Setup Initial Entities
    ${first_existing_entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    ${second_existing_entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Create Entity    building-minimal-sample.jsonld    ${first_existing_entity_id}
    Create Entity    building-minimal-sample.jsonld    ${second_existing_entity_id}
    Set Suite Variable    ${first_existing_entity_id}
    Set Suite Variable    ${second_existing_entity_id}

Delete Initial Entities
    @{entities_ids_to_be_deleted}=    Create List    ${first_existing_entity_id}    ${second_existing_entity_id}
    Batch Delete Entities    @{entities_ids_to_be_deleted}    teardown=True
