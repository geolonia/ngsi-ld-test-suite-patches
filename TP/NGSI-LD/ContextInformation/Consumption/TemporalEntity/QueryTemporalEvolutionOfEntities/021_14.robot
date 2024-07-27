*** Settings ***
Documentation       Check that one can query the temporal evolution of entities with the simplified representation

Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Setup Initial Entities
Test Teardown       Delete Initial Entities
Test Template       Query the temporal evolution of entities


*** Variables ***
${vehicule_id_prefix}=              urn:ngsi-ld:Vehicle:
${bus_id_prefix}=                   urn:ngsi-ld:Bus:
${first_vehicle_payload_file}=      2020-08-vehicule-temporal-representation-sample.jsonld
${second_vehicle_payload_file}=     2020-09-vehicule-temporal-representation-sample.jsonld
${bus_payload_file}=                2020-08-bus-temporal-representation-sample.jsonld


*** Test Cases ***    TIMEREL    TIMEAT    EXPECTATION_FILE
021_14_01 After
    [Tags]    te-query    5_7_4
    after    2020-08-01T12:04:00Z    vehicles-temporal-representation-021-14-01-expectation.json
021_14_02 Before
    [Tags]    te-query    5_7_4
    before    2020-09-01T13:06:00Z    vehicles-temporal-representation-021-14-02-expectation.json


*** Keywords ***
Query the temporal evolution of entities
    [Documentation]    Check that one can query the temporal evolution of entities with the simplified representation
    [Arguments]    ${timerel}    ${timeat}    ${expectation_file}
    ${entity_types_to_be_retrieved}=    Catenate    SEPARATOR=,    Vehicle
    ${response}=    Query Temporal Representation Of Entities
    ...    entity_types=${entity_types_to_be_retrieved}
    ...    timerel=${timerel}
    ...    timeAt=${timeat}
    ...    context=${ngsild_test_suite_context}
    ...    options=temporalValues
    @{temporal_entities_representation_ids}=    Create List
    ...    ${first_temporal_entity_representation_id}
    ...    ${second_temporal_entity_representation_id}
    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing List Containing EntityTemporal elements
    ...    ${expectation_file}
    ...    ${temporal_entities_representation_ids}
    ...    ${response.json()}

Setup Initial Entities
    ${first_temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicule_id_prefix}
    ${create_response1}=    Create Temporal Representation Of Entity
    ...    ${first_vehicle_payload_file}
    ...    ${first_temporal_entity_representation_id}
    Check Response Status Code    201    ${create_response1.status_code}
    Set Test Variable    ${first_temporal_entity_representation_id}
    ${second_temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicule_id_prefix}
    ${create_response2}=    Create Temporal Representation Of Entity
    ...    ${second_vehicle_payload_file}
    ...    ${second_temporal_entity_representation_id}
    Check Response Status Code    201    ${create_response2.status_code}
    Set Test Variable    ${second_temporal_entity_representation_id}
    ${third_temporal_entity_representation_id}=    Generate Random Entity Id    ${bus_id_prefix}
    ${create_response3}=    Create Temporal Representation Of Entity
    ...    ${bus_payload_file}
    ...    ${third_temporal_entity_representation_id}
    Check Response Status Code    201    ${create_response3.status_code}
    Set Test Variable    ${third_temporal_entity_representation_id}

Delete Initial Entities
    Delete Temporal Representation Of Entity    ${first_temporal_entity_representation_id}
    Delete Temporal Representation Of Entity    ${second_temporal_entity_representation_id}
    Delete Temporal Representation Of Entity    ${third_temporal_entity_representation_id}
