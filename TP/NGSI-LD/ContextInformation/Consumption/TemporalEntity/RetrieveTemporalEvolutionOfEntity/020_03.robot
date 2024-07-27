*** Settings ***
Documentation       Check that one can retrieve the temporal evolution of certain attributes of an entity

Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Create Temporal Entity
Test Teardown       Delete Initial Temporal Entity
Test Template       Retrieve the temporal evolution of certain attributes of an entity


*** Variables ***
${vehicule_id_prefix}=          urn:ngsi-ld:Vehicle:
${vehicle_payload_file}=        2020-08-vehicule-temporal-representation-sample.jsonld
${vehicle_expectation_file}=    vehicle-temporal-representation-020-03-expectation.jsonld


*** Test Cases ***    ATTRS    EXPECTED_RESULT
020_03_01 With one attribute
    [Tags]    te-retrieve    5_7_3
    fuelLevel    vehicle-temporal-representation-020-03-01.jsonld
020_03_02 With two attributes
    [Tags]    te-retrieve    5_7_3
    fuelLevel,speed    vehicle-temporal-representation-020-03-02.jsonld


*** Keywords ***
Retrieve the temporal evolution of certain attributes of an entity
    [Documentation]    Check that one can retrieve the temporal evolution of certain attributes of an entity
    [Arguments]    ${attrs}    ${expected_result}
    ${response}=    Retrieve Temporal Representation Of Entity
    ...    temporal_entity_representation_id=${temporal_entity_representation_id}
    ...    attrs=${attrs}
    ...    context=${ngsild_test_suite_context}
    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing EntityTemporal element
    ...    ${expected_result}
    ...    ${temporal_entity_representation_id}
    ...    ${response.json()}

Create Temporal Entity
    ${temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicule_id_prefix}
    ${create_response}=    Create Temporal Representation Of Entity
    ...    ${vehicle_payload_file}
    ...    ${temporal_entity_representation_id}
    Check Response Status Code    201    ${create_response.status_code}
    Set Suite Variable    ${temporal_entity_representation_id}

Delete Initial Temporal Entity
    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
