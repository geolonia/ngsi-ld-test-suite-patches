*** Settings ***
Documentation       Check that you can retrieve the temporal evolution of an entity

Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Create Temporal Entity
Suite Teardown      Delete Initial Temporal Entity


*** Variables ***
${vehicule_id_prefix}=          urn:ngsi-ld:Vehicle:
${vehicle_payload_file}=        2020-08-vehicule-temporal-representation-sample.jsonld
${vehicle_expectation_file}=    vehicle-temporal-representation-020-01-expectation.jsonld


*** Test Cases ***
020_01_01 Retrieve the temporal evolution of an entity
    [Documentation]    Check that you can retrieve the temporal evolution of an entity
    [Tags]    te-retrieve    5_7_3
    ${response}=    Retrieve Temporal Representation Of Entity
    ...    temporal_entity_representation_id=${temporal_entity_representation_id}
    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing EntityTemporal element
    ...    ${vehicle_expectation_file}
    ...    ${temporal_entity_representation_id}
    ...    ${response.json()}


*** Keywords ***
Create Temporal Entity
    ${temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicule_id_prefix}
    Create Temporal Representation Of Entity    ${vehicle_payload_file}    ${temporal_entity_representation_id}
    Set Suite Variable    ${temporal_entity_representation_id}

Delete Initial Temporal Entity
    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
