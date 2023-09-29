*** Settings ***
Documentation       Check that you can retrieve the temporal evolution of the last N instances of entity attributes

Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Setup Initial Entities
Test Teardown       Delete Initial Entities
Test Template       Retrieve the temporal evolution of the last N instances of entity attributes


*** Variables ***
${vehicule_id_prefix}=      urn:ngsi-ld:Vehicle:
${vehicle_payload_file}=    2020-08-vehicule-temporal-representation-multiple-instances-sample.jsonld


*** Test Cases ***    LASTN    VEHICLE_EXPECTATION_FILE
020_05_01 Retrieve Some Instances
    [Tags]    te-retrieve    5_7_3
    ${10}    vehicle-temporal-representation-020-05-01-expectation.jsonld
020_05_02 Retrieve All Instances
    [Tags]    te-retrieve    5_7_3
    ${20}    vehicle-temporal-representation-020-05-02-expectation.jsonld


*** Keywords ***
Retrieve the temporal evolution of the last N instances of entity attributes
    [Documentation]    Check that you can retrieve the temporal evolution of the last N instances of entity attributes
    [Arguments]    ${lastN}    ${vehicle_expectation_file}
    ${response}=    Retrieve Temporal Representation Of Entity
    ...    ${temporal_entity_representation_id}
    ...    lastN=${lastN}
    ...    context=${ngsild_test_suite_context}
    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing EntityTemporal element
    ...    ${vehicle_expectation_file}
    ...    ${temporal_entity_representation_id}
    ...    ${response.json()}

Setup Initial Entities
    ${temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicule_id_prefix}
    Create Temporal Representation Of Entity    ${vehicle_payload_file}    ${temporal_entity_representation_id}
    Set Test Variable    ${temporal_entity_representation_id}

Delete Initial Entities
    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
