*** Settings ***
Documentation       Check that an entity can be retrieved with a multivalued relationship

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Create Initial Entity
Suite Teardown      Delete Created Entity
Test Template       Retrieve Entity With Multivalued Relationship


*** Variables ***
${linking_entity_filename}=     building-multivalued-relationship.jsonld
${linked_entity_filename}=      city-minimal.jsonld


*** Test Cases ***    JOIN    OPTIONS    EXPECTATION_FILENAME
018_22_01 Retrieve Normalized
    [Documentation]    Check that an entity with a multivalued relationship can be retrieved
    [Tags]    e-retrieve    5_7_1    since_v1.8.1
    ${EMPTY}    ${EMPTY}    building-multivalued-relationship-normalized-018-22-01.json
018_22_02 Retrieve Simplified
    [Documentation]    Check that an entity with a multivalued relationship can be retrieved in simplified representation
    [Tags]    e-retrieve    5_7_1    since_v1.8.1
    ${EMPTY}    keyValues    building-multivalued-relationship-simplified-018-22-02.json
018_22_03 Retrieve Normalized With Inline Linked Entity Retrieval
    [Documentation]    Check that an entity with a multivalued relationship can be retrieved with inline linked entities
    [Tags]    e-retrieve    5_7_1    4_5_23    since_v1.8.1
    inline    ${EMPTY}    linked-entity-retrieval/building-multivalued-relationship-inline-018-22-03.json
018_22_04 Retrieve Normalized With Flat Linked Entity Retrieval
    [Documentation]    Check that an entity with a multivalued relationship can be retrieved with flat linked entities
    [Tags]    e-retrieve    5_7_1    4_5_23    since_v1.8.1
    flat    ${EMPTY}    linked-entity-retrieval/building-multivalued-relationship-flat-018-22-04.json
018_22_05 Retrieve Simplified With Inline Linked Entity Retrieval
    [Documentation]    Check that an entity with a multivalued relationship can be retrieved with inline linked entities in simplified representation
    [Tags]    e-retrieve    5_7_1    4_5_23    since_v1.8.1
    inline    keyValues    linked-entity-retrieval/building-multivalued-relationship-inline-simplified-018-22-05.json


*** Keywords ***
Retrieve Entity With Multivalued Relationship
    [Documentation]    Check that an entity can be retrieved with a multivalued relationship
    [Arguments]    ${join}    ${options}    ${expectation_filename}
    ${join_level}=    Set Variable If    '${join}' == '${EMPTY}'    ${EMPTY}    1

    ${response}=    Retrieve Entity
    ...    id=${linking_entity_id}
    ...    join=${join}
    ...    joinLevel=${join_level}
    ...    options=${options}
    ...    context=${ngsild_test_suite_context}

    Check Response Status Code    200    ${response.status_code}
    Check Response Body Content
    ...    expectation_filename=${expectation_filename}
    ...    response_body=${response.json()}

Create Initial Entity
    ${linking_entity_id}=    Catenate    ${BUILDING_ID_PREFIX}018-22
    Set Suite Variable    ${linking_entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${linking_entity_filename}
    ...    ${linking_entity_id}
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
    Delete Entity    ${linking_entity_id}
    Delete Entity    ${first_linked_entity_id}
    Delete Entity    ${second_linked_entity_id}
