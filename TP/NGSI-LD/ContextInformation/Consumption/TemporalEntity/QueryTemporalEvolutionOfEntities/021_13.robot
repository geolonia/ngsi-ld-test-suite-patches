*** Settings ***
Documentation       Check that one can query the temporal evolution of entities using the entityOperations method

Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Setup Initial Temporal Entities
Test Teardown       Delete Initial Temporal Entities
Test Template       Query the temporal evolution of entities using the entityOperations method


*** Variables ***
${vehicle_id_prefix}=               urn:ngsi-ld:Vehicle:
${first_vehicle_payload_file}=      2020-08-vehicle-temporal-representation.jsonld
${second_vehicle_payload_file}=     2020-09-vehicle-temporal-representation.jsonld


*** Test Cases ***    PAYLOAD_FILE    EXPECTATION_FILE
021_13_01 After
    [Tags]    te-query    5_7_4
    entity-operations-after-query.jsonld    vehicles-temporal-representation-021-13-01.jsonld
021_13_02 Before
    [Tags]    te-query    5_7_4
    entity-operations-before-query.jsonld    vehicles-temporal-representation-021-13-02.jsonld
021_13_03 Between
    [Tags]    te-query    5_7_4
    entity-operations-between-query.jsonld    vehicles-temporal-representation-021-13-03.jsonld


*** Keywords ***
Query the temporal evolution of entities using the entityOperations method
    [Documentation]    Check that one can query the temporal evolution of entities using the entityOperations method
    [Arguments]    ${payload_file}    ${expectation_file}
    ${response}=    Query Temporal Representation Of Entities Via Post
    ...    query_file_name=${payload_file}
    ...    context=${ngsild_test_suite_context}
    @{temporal_entities_representation_ids}=    Create List
    ...    ${first_temporal_entity_representation_id}
    ...    ${second_temporal_entity_representation_id}
    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing List Containing EntityTemporal elements
    ...    ${expectation_file}
    ...    ${temporal_entities_representation_ids}
    ...    ${response.json()}

Setup Initial Temporal Entities
    ${first_temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    ${create_response1}=    Create Temporal Representation Of Entity
    ...    ${first_vehicle_payload_file}
    ...    ${first_temporal_entity_representation_id}
    Check Response Status Code    201    ${create_response1.status_code}
    Set Test Variable    ${first_temporal_entity_representation_id}
    ${second_temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    ${create_response2}=    Create Temporal Representation Of Entity
    ...    ${second_vehicle_payload_file}
    ...    ${second_temporal_entity_representation_id}
    Check Response Status Code    201    ${create_response2.status_code}
    Set Test Variable    ${second_temporal_entity_representation_id}

Delete Initial Temporal Entities
    Delete Temporal Representation Of Entity    ${first_temporal_entity_representation_id}
    Delete Temporal Representation Of Entity    ${second_temporal_entity_representation_id}
