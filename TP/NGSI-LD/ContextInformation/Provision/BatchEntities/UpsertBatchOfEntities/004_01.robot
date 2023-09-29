*** Settings ***
Documentation       Check that you can upsert a batch of non-existing entities and they will be created

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Teardown       Delete Initial Entities
Test Template       Batch Upsert Entity Scenarios


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:


*** Test Cases ***    FILENAME
004_01_01 EntityWithSimpleProperties
    [Tags]    be-upsert    5_6_8
    building-simple-attributes-sample.jsonld
004_01_02 EntityWithSimpleRelationships
    [Tags]    be-upsert    5_6_8
    building-relationship-sample.jsonld
004_01_03 EntityWithRelationshipsProperties
    [Tags]    be-upsert    5_6_8
    building-relationship-of-property-sample.jsonld


*** Keywords ***
Batch Upsert Entity Scenarios
    [Documentation]    Check that you can upsert a batch of non-existing entities
    [Arguments]    ${filename}
    ${first_entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    ${second_entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    ${first_entity}=    Load Entity    ${filename}    ${first_entity_id}
    ${second_entity}=    Load Entity    ${filename}    ${second_entity_id}
    @{entities_to_be_upserted}=    Create List    ${first_entity}    ${second_entity}
    ${response}=    Batch Upsert Entities    @{entities_to_be_upserted}
    @{expected_entities_ids}=    Create List    ${first_entity_id}    ${second_entity_id}
    Set Test Variable    @{expected_entities_ids}
    Check Response Status Code    201    ${response.status_code}
    Check Response Body Containing Array Of URIs set to    ${expected_entities_ids}    ${response.json()}
    ${expected_updated_entities_ids}=    Catenate    SEPARATOR=,    @{expected_entities_ids}
    ${response}=    Query Entities
    ...    ${expected_updated_entities_ids}
    ...    Building
    ...    context=${ngsild_test_suite_context}
    ...    accept=${CONTENT_TYPE_LD_JSON}
    Check Updated Resources Set To    ${entities_to_be_upserted}    ${response.json()}
    ${response}=    Batch Delete Entities    @{expected_entities_ids}

Delete Initial Entities
    Batch Delete Entities    @{expected_entities_ids}
