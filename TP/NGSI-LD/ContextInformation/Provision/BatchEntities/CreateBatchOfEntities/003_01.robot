*** Settings ***
Documentation       Check that you can create a batch of entities

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Template       Batch Create Entity Scenarios


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:


*** Test Cases ***    FILENAME
MinimalEntity    [Tags]    be-create    5_6_7
    building-minimal-sample.jsonld
EntityWithSimpleProperties
    [Tags]    be-create    5_6_7
    building-simple-attributes-sample.jsonld
EntityWithSimpleRelationships
    [Tags]    be-create    5_6_7
    building-relationship-sample.jsonld
EntityWithRelationshipsProperties
    [Tags]    be-create    5_6_7
    building-relationship-of-property-sample.jsonld


*** Keywords ***
Batch Create Entity Scenarios
    [Documentation]    Check that you can create a batch of entities
    [Arguments]    ${filename}
    ${first_entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    ${second_entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    ${first_entity}=    Load Entity    ${filename}    ${first_entity_id}
    ${second_entity}=    Load Entity    ${filename}    ${second_entity_id}
    @{entities_to_be_created}=    Create List    ${first_entity}    ${second_entity}
    Batch Create Entities    @{entities_to_be_created}
    @{expected_entities_ids}=    Create List    ${first_entity_id}    ${second_entity_id}
    ${entities_to_be_queried}=    Catenate    SEPARATOR=,    ${first_entity_id}    ${second_entity_id}
    Check Response Status Code Set To    201
    Check Response Body Containing Array Of URIs set to    @{expected_entities_ids}
    Query Entities
    ...    ${entities_to_be_queried}
    ...    Building
    ...    context=${ngsild_test_suite_context}
    ...    accept=${CONTENT_TYPE_LD_JSON}
    Check Created Resources Set To    ${entities_to_be_created}
    Batch Delete Entities    @{expected_entities_ids}
