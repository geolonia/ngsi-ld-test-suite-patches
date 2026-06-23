*** Settings ***
Documentation       Check that entities can be queried with a multivalued relationship

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Create Initial Entity
Suite Teardown      Delete Created Entity
Test Template       Query Entities With Multivalued Relationship


*** Variables ***
${entity_with_multivalued_relationship_filename}=     building-multivalued-relationship.jsonld
${linked_entity_filename}=      city-minimal.jsonld


*** Test Cases ***    JOIN    OPTIONS    EXPECTATION_FILENAME
019_30_01 Query Normalized
    [Documentation]    Check that entities with a multivalued relationship can be queried
    [Tags]    e-query    5_7_2    since_v1.8.1
    ${EMPTY}    ${EMPTY}    buildings-multivalued-relationship-normalized-019-30-01.json
019_30_02 Query Simplified
    [Documentation]    Check that entities with a multivalued relationship can be queried in simplified representation
    [Tags]    e-query    5_7_2    since_v1.8.1
    ${EMPTY}    keyValues    buildings-multivalued-relationship-simplified-019-30-02.json
019_30_03 Query Inline Normalized
    [Documentation]    Check that entities with a multivalued relationship can be queried with inline linked entities
    [Tags]    e-query    5_7_2    4_5_23    since_v1.8.1
    inline    ${EMPTY}    linked-entity-retrieval/buildings-multivalued-relationship-inline-019-30-03.json
019_30_04 Query Flat Normalized
    [Documentation]    Check that entities with a multivalued relationship can be queried with flat linked entities
    [Tags]    e-query    5_7_2    4_5_23    since_v1.8.1
    flat    ${EMPTY}    linked-entity-retrieval/buildings-multivalued-relationship-flat-019-30-04.json
019_30_05 Query Inline Simplified
    [Documentation]    Check that entities with a multivalued relationship can be queried with inline linked entities in simplified representation
    [Tags]    e-query    5_7_2    4_5_23    since_v1.8.1
    inline    keyValues    linked-entity-retrieval/buildings-multivalued-relationship-inline-simplified-019-30-05.json

*** Keywords ***
Query Entities With Multivalued Relationship
    [Documentation]    Check that entities can be queried with a multivalued relationship and linked entities
    [Arguments]    ${join}    ${options}    ${expectation_filename}
    ${join_level}=    Set Variable If    '${join}' == '${EMPTY}'    ${EMPTY}    1

    ${response}=    Query Entities
    ...    entity_ids=${initial_entity_id}
    ...    entity_types=Building
    ...    options=${options}
    ...    join=${join}
    ...    joinLevel=${join_level}
    ...    context=${ngsild_test_suite_context}

    Check Response Status Code    200    ${response.status_code}
    Check Response Body Content
    ...    expectation_filename=${expectation_filename}
    ...    response_body=${response.json()}

Create Initial Entity
    ${initial_entity_id}=    Catenate    ${BUILDING_ID_PREFIX}019-30
    Set Suite Variable    ${initial_entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${entity_with_multivalued_relationship_filename}
    ...    ${initial_entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}

    ${first_linked_entity_id}=    Catenate    ${CITY_ID_PREFIX}Paris
    Set Suite Variable    ${first_linked_entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${linked_entity_filename}
    ...    ${first_linked_entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}

    ${second_linked_entity_id}=    Catenate    ${CITY_ID_PREFIX}Lyon
    Set Suite Variable    ${second_linked_entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${linked_entity_filename}
    ...    ${second_linked_entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}

Delete Created Entity
    Delete Entity    ${initial_entity_id}
    Delete Entity    ${first_linked_entity_id}
    Delete Entity    ${second_linked_entity_id}
