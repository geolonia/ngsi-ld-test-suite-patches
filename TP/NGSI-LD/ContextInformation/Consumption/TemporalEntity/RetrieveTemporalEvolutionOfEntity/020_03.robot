*** Settings ***
Documentation     Check that you can retrieve the temporal evolution of certain attributes of an entity
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Suite Setup       Setup Initial Entities
Suite Teardown    Delete Initial Entities

*** Variable ***
${vehicule_id_prefix}=    urn:ngsi-ld:Vehicle:
${vehicle_payload_file}=    2020-08-vehicule-temporal-representation-sample.jsonld
${vehicle_expectation_file}=    vehicle-temporal-representation-020-03-expectation.jsonld

*** Test Case ***
Retrieve the temporal evolution of certain attributes of an entity
    [Documentation]    Check that you can retrieve the temporal evolution of certain attributes of an entity
    [Tags]    te-retrieve    5_7_3
    @{temporal_attributes_to_be_retrieved}=    Create List    fuelLevel
    Retrieve Temporal Representation Of Entity    ${temporal_entity_representation_id}    attrs=${temporal_attributes_to_be_retrieved}    context=${ngsild_test_suite_context}
    Check Response Status Code Set To    200
    Check Response Body Containing EntityTemporal element    ${vehicle_expectation_file}    ${temporal_entity_representation_id}

*** Keywords ***
Setup Initial Entities
    ${temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicule_id_prefix}
    Create Temporal Representation Of Entity    ${vehicle_payload_file}    ${temporal_entity_representation_id}
    Set Suite Variable    ${temporal_entity_representation_id}

Delete Initial Entities
    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
