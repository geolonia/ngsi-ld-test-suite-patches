*** Settings ***
Documentation     Check that you can query the temporal evolution of entities
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Suite Setup       Setup Initial Entities
Suite Teardown    Delete Initial Entities
Test Template     Query the temporal evolution of entities

*** Variable ***
${vehicule_id_prefix}=    urn:ngsi-ld:Vehicle:
${bus_id_prefix}=    urn:ngsi-ld:Bus:
${first_vehicle_payload_file}=    2020-08-vehicule-temporal-representation-sample.jsonld
${second_vehicle_payload_file}=    2020-09-vehicule-temporal-representation-sample.jsonld
${bus_payload_file}=    2020-08-bus-temporal-representation-sample.jsonld

*** Test Cases ***    TIMEREL    TIMEAT                  EXPECTATION_FILE
After                 after      2020-08-01T12:04:00Z    vehicles-temporal-representation-021-01-01-expectation.jsonld
                      [Tags]     te-query                5_7_4

Before                before     2020-09-01T13:06:00Z    vehicles-temporal-representation-021-01-02-expectation.jsonld
                      [Tags]     te-query                5_7_4

*** Keywords ***
Query the temporal evolution of entities
    [Arguments]    ${timerel}    ${timeAt}    ${expectation_file}
    [Documentation]    Check that you can query the temporal evolution of entities
    ${entity_types_to_be_retrieved}=    Catenate    SEPARATOR=,    Vehicle
    Query Temporal Representation Of Entities    entity_types=${entity_types_to_be_retrieved}    timerel=${timerel}    timeAt=${timeAt}    context=${ngsild_test_suite_context}
    @{temporal_entities_representation_ids}=    Create List    ${first_temporal_entity_representation_id}    ${second_temporal_entity_representation_id}
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
