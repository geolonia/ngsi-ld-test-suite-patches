*** Settings ***
Documentation     Check that you can query the temporal evolution of entities with a limit to the number of entities to be retrieved
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Suite Setup       Setup Initial Entities
Suite Teardown    Delete Initial Entities
Test Template     Query the temporal evolution of entities with a limit to the number of entities to be retrieved

*** Variable ***
${vehicule_id_prefix}=    urn:ngsi-ld:Vehicle:
${bus_id_prefix}=    urn:ngsi-ld:Bus:
${first_vehicle_payload_file}=    2020-08-vehicule-temporal-representation-sample.jsonld
${second_vehicle_payload_file}=    2020-09-vehicule-temporal-representation-sample.jsonld
${bus_payload_file}=    2020-08-bus-temporal-representation-sample.jsonld
${expectation_file}=    vehicles-temporal-representation-021-11-expectation.jsonld

*** Test Cases ***    LIMIT     EXPECTATION_FILE                                                 TEMPORAL_ENTITIES_REPRESENTATION_IDS
Query Some entities
                      ${2}      vehicles-temporal-representation-021-11-01-expectation.jsonld    ${first_temporal_entity_representation_id}    ${second_temporal_entity_representation_id}
                      [Tags]    te-query                                                         5_7_4

Query All entities
                      ${20}     vehicles-temporal-representation-021-11-02-expectation.jsonld    ${first_temporal_entity_representation_id}    ${second_temporal_entity_representation_id}    ${third_temporal_entity_representation_id}
                      [Tags]    te-query                                                         5_7_4

*** Keywords ***
Query the temporal evolution of entities with a limit to the number of entities to be retrieved
    [Arguments]    ${limit}    ${expectation_file}    @{temporal_entities_representation_ids}
    [Documentation]    Check that you can query the temporal evolution of entities with a limit to the number of entities to be retrieved
    ${entity_types_to_be_retrieved}=    Catenate    SEPARATOR=,    Bus
    Query Temporal Representation Of Entities    entity_types=${entity_types_to_be_retrieved}    limit=${limit}    timerel=after    timeAt=2020-07-01T12:05:00Z    context=${ngsild_test_suite_context}
    Check Response Status Code Set To    200
    Check Response Body Containing List Containing EntityTemporal elements    ${expectation_file}    ${temporal_entities_representation_ids}

Setup Initial Entities
    ${first_temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicule_id_prefix}
    ${second_temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicule_id_prefix}
    ${third_temporal_entity_representation_id}=    Generate Random Entity Id    ${bus_id_prefix}
    Create Temporal Representation Of Entity    ${first_vehicle_payload_file}    ${first_temporal_entity_representation_id}
    Create Temporal Representation Of Entity    ${second_vehicle_payload_file}    ${second_temporal_entity_representation_id}
    Create Temporal Representation Of Entity    ${bus_payload_file}    ${third_temporal_entity_representation_id}
    Set Suite Variable    ${first_temporal_entity_representation_id}
    Set Suite Variable    ${second_temporal_entity_representation_id}
    Set Suite Variable    ${third_temporal_entity_representation_id}

Delete Initial Entities
    Delete Temporal Representation Of Entity    ${first_temporal_entity_representation_id}
    Delete Temporal Representation Of Entity    ${second_temporal_entity_representation_id}
    Delete Temporal Representation Of Entity    ${third_temporal_entity_representation_id}
