*** Settings ***
Documentation       Check that one can retrieve the temporal evolution of an entity with the aggregated temporal representation

Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Create Temporal Entity
Suite Teardown      Delete Initial Temporal Entity
Test Template       Retrieve the temporal evolution of an entity with the aggregated temporal representation


*** Variables ***
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:
${vehicle_payload_file}=    2020-08-vehicle-temporal-representation.jsonld


*** Test Cases ***    AGGRMETHODS    AGGRPERIODDURATION    ATTRS    VEHICLE_EXPECTATION_FILE
020_11_01 One aggregate method aggregated by one hour duration
    [Tags]    te-retrieve    5_7_3    4_5_19    since_v1.4.1
    avg    PT1H    ${EMPTY}    vehicle-temporal-representation-020-11-01.json
020_11_02 One aggregate method aggregated by one hour duration asking for one attribute
    [Tags]    te-retrieve    5_7_3    4_5_19    since_v1.4.1
    avg    PT1H    fuelLevel    vehicle-temporal-representation-020-11-02.json
020_11_03 Multiple aggregate methods aggregated by one hour duration
    [Tags]    te-retrieve    5_7_3    4_5_19    since_v1.4.1
    avg,max    PT1H    ${EMPTY}    vehicle-temporal-representation-020-11-03.json
020_11_04 Multiple aggregate methods aggregated by one day duration
    [Tags]    te-retrieve    5_7_3    4_5_19    since_v1.4.1
    min,max    P1D    ${EMPTY}    vehicle-temporal-representation-020-11-04.json


*** Keywords ***
Retrieve the temporal evolution of an entity with the aggregated temporal representation
    [Documentation]    Check that one can retrieve the temporal evolution of an entity with the aggregated temporal representation
    [Arguments]    ${aggrmethods}    ${aggrperiodduration}    ${attrs}    ${vehicle_expectation_file}
    @{options}=    Create List    aggregatedValues
    ${response}=    Retrieve Temporal Representation Of Entity
    ...    temporal_entity_representation_id=${temporal_entity_representation_id}
    ...    attrs=${attrs}
    ...    options=${options}
    ...    aggrMethods=${aggrmethods}
    ...    aggrPeriodDuration=${aggrperiodduration}
    ...    context=${ngsild_test_suite_context}
    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing EntityTemporal element
    ...    ${vehicle_expectation_file}
    ...    ${temporal_entity_representation_id}
    ...    ${response.json()}

Create Temporal Entity
    ${temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    ${create_response}=    Create Temporal Representation Of Entity
    ...    ${vehicle_payload_file}
    ...    ${temporal_entity_representation_id}
    Check Response Status Code    201    ${create_response.status_code}
    Set Suite Variable    ${temporal_entity_representation_id}

Delete Initial Temporal Entity
    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
