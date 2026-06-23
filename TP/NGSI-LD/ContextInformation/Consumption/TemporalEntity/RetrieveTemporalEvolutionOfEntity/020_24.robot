*** Settings ***
Documentation       Check that one can retrieve the temporal evolution of an entity with a multivalued relationship

Resource            ${EXECDIR}/resources/ApiUtils/Common.resource
Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Create Temporal Entity
Suite Teardown      Delete Initial Temporal Entity
Test Template       Retrieve Temporal Entity With Multivalued Relationship


*** Variables ***
${vehicle_payload_file}=    vehicle-temporal-representation-multivalued-relationship.jsonld


*** Test Cases ***    REPRESENTATION    EXPECTATION_FILENAME
020_24_01 Retrieve The Temporal Evolution Of An Entity With A Multivalued Relationship
    [Tags]    te-retrieve    5_7_3    since_v1.8.1
    ${EMPTY}    vehicle-temporal-representation-multivalued-relationship.json
020_24_02 Retrieve The Simplified Temporal Evolution Of An Entity With A Multivalued Relationship
    [Tags]    te-retrieve    5_7_3    4_5_9    since_v1.8.1
    temporalValues    vehicle-temporal-representation-multivalued-relationship-simplified.json


*** Keywords ***
Retrieve Temporal Entity With Multivalued Relationship
    [Documentation]    Check that one can retrieve the temporal evolution of an entity with a multivalued relationship
    [Arguments]    ${representation}    ${expectation_filename}
    ${response}=    Retrieve Temporal Representation Of Entity
    ...    temporal_entity_representation_id=${temporal_entity_representation_id}
    ...    options=${representation}
    ...    context=${ngsild_test_suite_context}
    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing EntityTemporal element
    ...    ${expectation_filename}
    ...    ${temporal_entity_representation_id}
    ...    ${response.json()}


Create Temporal Entity
    ${temporal_entity_representation_id}=    Generate Random Vehicle Entity Id
    ${create_response}=    Create Temporal Representation Of Entity
    ...    ${vehicle_payload_file}
    ...    ${temporal_entity_representation_id}
    Check Response Status Code    201    ${create_response.status_code}
    Set Suite Variable    ${temporal_entity_representation_id}

Delete Initial Temporal Entity
    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
