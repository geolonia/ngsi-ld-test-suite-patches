*** Settings ***
Documentation       Check that one can query the temporal evolution of entities matching the given NGSI-LD query

Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Setup Initial Temporal Entities
Suite Teardown      Delete Initial Temporal Entities


*** Variables ***
${vehicule_id_prefix}=              urn:ngsi-ld:Vehicle:
${first_vehicle_payload_file}=      2020-08-vehicule-temporal-representation-sample.jsonld
${second_vehicle_payload_file}=     2020-09-vehicule-temporal-representation-sample.jsonld
${expectation_file}=                vehicles-temporal-representation-021-08-expectation.jsonld


*** Test Cases ***
021_08_01 Query the temporal evolution of entities matching the given NGSI-LD query
    [Documentation]    Check that one can query the temporal evolution of entities matching the given NGSI-LD query
    [Tags]    te-query    5_7_4
    ${entity_types_to_be_retrieved}=    Catenate    SEPARATOR=,    Vehicle
    ${response}=    Query Temporal Representation Of Entities
    ...    entity_types=${entity_types_to_be_retrieved}
    ...    ngsild_query=speed>90
    ...    timerel=after
    ...    timeAt=2020-07-01T12:05:00Z
    ...    context=${ngsild_test_suite_context}
    @{temporal_entities_representation_ids}=    Create List
    ...    ${first_temporal_entity_representation_id}
    ...    ${second_temporal_entity_representation_id}
    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing List Containing EntityTemporal elements
    ...    ${expectation_file}
    ...    ${temporal_entities_representation_ids}
    ...    ${response.json()}


*** Keywords ***
Setup Initial Temporal Entities
    ${first_temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicule_id_prefix}
    ${second_temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicule_id_prefix}
    Create Temporal Representation Of Entity
    ...    ${first_vehicle_payload_file}
    ...    ${first_temporal_entity_representation_id}
    Create Temporal Representation Of Entity
    ...    ${second_vehicle_payload_file}
    ...    ${second_temporal_entity_representation_id}
    Set Suite Variable    ${first_temporal_entity_representation_id}
    Set Suite Variable    ${second_temporal_entity_representation_id}

Delete Initial Temporal Entities
    Delete Temporal Representation Of Entity    ${first_temporal_entity_representation_id}
    Delete Temporal Representation Of Entity    ${second_temporal_entity_representation_id}
