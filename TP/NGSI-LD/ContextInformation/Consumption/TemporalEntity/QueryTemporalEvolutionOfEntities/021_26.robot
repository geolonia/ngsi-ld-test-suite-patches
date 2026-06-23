*** Settings ***
Documentation       Check that one can query the temporal evolution of entities with a multivalued relationship

Resource            ${EXECDIR}/resources/ApiUtils/Common.resource
Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Create Temporal Entity
Suite Teardown      Delete Initial Temporal Entity
Test Template       Query Temporal Entities With Multivalued Relationship


*** Variables ***
${vehicle_payload_file}=    vehicle-temporal-representation-multivalued-relationship.jsonld


*** Test Cases ***    REPRESENTATION    EXPECTATION_FILENAME
021_26_01 Query The Temporal Evolution Of Entities With A Multivalued Relationship
    [Tags]    te-query    5_7_4    since_v1.8.1
    ${EMPTY}    vehicle-temporal-representation-multivalued-relationship.json
021_26_02 Query The Simplified Temporal Evolution Of Entities With A Multivalued Relationship
    [Tags]    te-query    5_7_4    4_5_9    since_v1.8.1
    temporalValues    vehicle-temporal-representation-multivalued-relationship-simplified.json


*** Keywords ***
Query Temporal Entities With Multivalued Relationship
    [Documentation]    Check that one can query the temporal evolution of entities with a multivalued relationship
    [Arguments]    ${representation}    ${expectation_filename}
    ${response}=    Query Temporal Representation Of Entities
    ...    entity_ids=${temporal_entity_representation_id}
    ...    entity_types=Vehicle
    ...    timerel=after
    ...    timeAt=2020-07-01T12:05:00Z
    ...    options=${representation}
    ...    context=${ngsild_test_suite_context}
    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing EntityTemporal element
    ...    ${expectation_filename}
    ...    ${temporal_entity_representation_id}
    ...    ${response.json()[0]}


Create Temporal Entity
    ${temporal_entity_representation_id}=    Catenate    ${VEHICLE_ID_PREFIX}021-26
    ${create_response}=    Create Temporal Representation Of Entity
    ...    ${vehicle_payload_file}
    ...    ${temporal_entity_representation_id}
    Check Response Status Code    201    ${create_response.status_code}
    Set Suite Variable    ${temporal_entity_representation_id}

Delete Initial Temporal Entity
    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
