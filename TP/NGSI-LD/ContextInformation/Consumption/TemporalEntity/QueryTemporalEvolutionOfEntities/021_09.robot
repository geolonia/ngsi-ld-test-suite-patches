*** Settings ***
Documentation     Check that you can query the temporal evolution of entities matching the given NGSI-LD geo-query
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Suite Setup       Setup Initial Entities
Suite Teardown    Delete Initial Entities
Test Template     Query the temporal evolution of entities matching the given NGSI-LD geo-query

*** Variable ***
${vehicule_id_prefix}=    urn:ngsi-ld:Vehicle:
${first_vehicle_payload_file}=    2020-08-vehicule-temporal-representation-sample.jsonld
${second_vehicle_payload_file}=    2020-10-vehicule-temporal-representation-with-location-sample.jsonld
${expectation_file}=    vehicles-temporal-representation-021-09-expectation.jsonld

*** Test Cases ***    GEOREL                    GEOMETRY    COORDINATES                                                                      GEOPROPERTY    EXPECTATION_FILE
Near Point            near;maxDistance==2000    Point       [-8.503,41.202]                                                                  ${EMPTY}       vehicles-temporal-representation-021-09-01-expectation.jsonld
                      [Tags]                    te-query    5_7_4

Within Polygon        within                    Polygon     [[-13.503,47.202],[6.541, 52.961],[20.37,44.653],[9.46,32.57],[-15.23,21.37]]    location       vehicles-temporal-representation-021-09-02-expectation.jsonld
                      [Tags]                    te-query    5_7_4

*** Keywords ***
Query the temporal evolution of entities matching the given NGSI-LD geo-query
    [Arguments]    ${georel}    ${geometry}    ${coordinates}    ${geoproperty}    ${expectation_file}
    [Documentation]    Check that you can query the temporal evolution of entities matching the given NGSI-LD geo-query
    ${entity_types_to_be_retrieved}=    Catenate    SEPARATOR=,    Vehicle
    Query Temporal Representation Of Entities    entity_types=${entity_types_to_be_retrieved}    georel=${georel}    geometry=${geometry}    coordinates=${coordinates}    geoproperty=${geoproperty}    timerel=after    timeAt=2020-07-01T12:05:00Z    context=${ngsild_test_suite_context}
    @{temporal_entities_representation_ids}=    Create List    ${second_temporal_entity_representation_id}
    Check Response Status Code Set To    200
    Check Response Body Containing List Containing EntityTemporal elements    ${expectation_file}    ${temporal_entities_representation_ids}

Setup Initial Entities
    ${first_temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicule_id_prefix}
    ${second_temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicule_id_prefix}
    Create Temporal Representation Of Entity    ${first_vehicle_payload_file}    ${first_temporal_entity_representation_id}
    Create Temporal Representation Of Entity    ${second_vehicle_payload_file}    ${second_temporal_entity_representation_id}
    Set Suite Variable    ${first_temporal_entity_representation_id}
    Set Suite Variable    ${second_temporal_entity_representation_id}

Delete Initial Entities
    Delete Temporal Representation Of Entity    ${first_temporal_entity_representation_id}
    Delete Temporal Representation Of Entity    ${second_temporal_entity_representation_id}
