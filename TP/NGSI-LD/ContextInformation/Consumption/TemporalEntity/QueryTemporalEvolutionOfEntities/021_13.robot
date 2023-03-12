*** Settings ***
Documentation     Check that you can query the temporal evolution of entities using the entityOperations method
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Suite Setup       Setup Initial Entities
Suite Teardown    Delete Initial Entities
Test Template     Query the temporal evolution of entities using the entityOperations method

*** Variable ***
${vehicule_id_prefix}=    urn:ngsi-ld:Vehicle:
${first_vehicle_payload_file}=    2020-08-vehicule-temporal-representation-sample.jsonld
${second_vehicle_payload_file}=    2020-09-vehicule-temporal-representation-sample.jsonld

*** Test Cases ***    PAYLOAD_FILE                             EXPECTATION_FILE
After                 entity-operations-after-query.jsonld     vehicles-temporal-representation-021-13-01-expectation.jsonld
                      [Tags]                                   te-query                                                         5_7_4

Before                entity-operations-before-query.jsonld    vehicles-temporal-representation-021-13-02-expectation.jsonld
                      [Tags]                                   te-query                                                         5_7_4

*** Keywords ***
Query the temporal evolution of entities using the entityOperations method
    [Arguments]    ${payload_file}    ${expectation_file}
    [Documentation]    Check that you can query the temporal evolution of entities using the entityOperations method
    Query Temporal Representation Of Entities Via Post    ${payload_file}   context=${ngsild_test_suite_context}
    @{temporal_entities_representation_ids}=    Create List    ${first_temporal_entity_representation_id}    ${second_temporal_entity_representation_id}
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
