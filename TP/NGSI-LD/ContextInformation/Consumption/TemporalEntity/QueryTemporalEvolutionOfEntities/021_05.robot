*** Settings ***
Documentation     Check that you can query the temporal evolution of entities matching the given type(s)
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Suite Setup       Setup Initial Entities
Suite Teardown    Delete Initial Entities

*** Variable ***
${vehicule_id_prefix}=    urn:ngsi-ld:Vehicle:
${bus_id_prefix}=    urn:ngsi-ld:Bus:
${vehicle_payload_file}=    2020-08-vehicule-temporal-representation-sample.jsonld
${bus_payload_file}=    2020-08-bus-temporal-representation-sample.jsonld
${expectation_file}=    vehicles-temporal-representation-021-05-expectation.jsonld

*** Test Case ***
Query the temporal evolution of entities matching the given type(s)
    [Documentation]    Check that you can query the temporal evolution of entities matching the given type(s)
    [Tags]    te-query    5_7_4
    ${entity_types_to_be_retrieved}=    Catenate    SEPARATOR=,    Bus
    Query Temporal Representation Of Entities    entity_types=${entity_types_to_be_retrieved}    timerel=after    timeAt=2020-07-01T12:05:00Z    context=${ngsild_test_suite_context}
    @{temporal_entities_representation_ids}=    Create List    ${first_temporal_entity_representation_id}    ${second_temporal_entity_representation_id}
    Check Response Status Code Set To    200
    Check Response Body Containing List Containing EntityTemporal elements    ${expectation_file}    ${temporal_entities_representation_ids}

*** Keywords ***
Setup Initial Entities
    ${first_temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicule_id_prefix}
    ${second_temporal_entity_representation_id}=    Generate Random Entity Id    ${bus_id_prefix}
    Create Temporal Representation Of Entity    ${vehicle_payload_file}    ${first_temporal_entity_representation_id}
    Create Temporal Representation Of Entity    ${bus_payload_file}    ${second_temporal_entity_representation_id}
    Set Suite Variable    ${first_temporal_entity_representation_id}
    Set Suite Variable    ${second_temporal_entity_representation_id}

Delete Initial Entities
    Delete Temporal Representation Of Entity    ${first_temporal_entity_representation_id}
    Delete Temporal Representation Of Entity    ${second_temporal_entity_representation_id}
