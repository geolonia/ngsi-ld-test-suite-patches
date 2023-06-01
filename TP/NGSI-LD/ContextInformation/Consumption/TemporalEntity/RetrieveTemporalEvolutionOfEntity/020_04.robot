*** Settings ***
Documentation       Check that you can retrieve the temporal evolution of an entity matching the given NGSI-LD temporal query

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Setup Initial Entities
Suite Teardown      Delete Initial Entities
Test Template       Retrieve the temporal evolution of an entity matching the given NGSI-LD temporal query


*** Variables ***
${vehicule_id_prefix}=      urn:ngsi-ld:Vehicle:
${vehicle_payload_file}=    2020-08-vehicule-temporal-representation-sample.jsonld


*** Test Cases ***    TIMEREL    TIMEAT    ENDTIMEAT    VEHICLE_EXPECTATION_FILE
After    [Tags]    te-retrieve    5_7_3
    after    2020-08-01T13:03:00Z    ${EMPTY}    vehicle-temporal-representation-020-04-01-expectation.jsonld
Before    [Tags]    te-retrieve    5_7_3
    before    2020-08-01T12:05:00Z    ${EMPTY}    vehicle-temporal-representation-020-04-02-expectation.jsonld
Between    [Tags]    te-retrieve    5_7_3
    between    2020-08-01T12:00:00Z    2020-08-01T13:00:00Z    vehicle-temporal-representation-020-04-03-expectation.jsonld


*** Keywords ***
Retrieve the temporal evolution of an entity matching the given NGSI-LD temporal query
    [Documentation]    Check that you can retrieve the temporal evolution of an entity matching the given NGSI-LD temporal query
    [Arguments]    ${timerel}    ${timeAt}    ${endTimeAt}    ${vehicle_expectation_file}
    ${response}=    Retrieve Temporal Representation Of Entity
    ...    ${temporal_entity_representation_id}
    ...    timerel=${timerel}
    ...    timeAt=${timeAt}
    ...    endTimeAt=${endTimeAt}
    ...    context=${ngsild_test_suite_context}
    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing EntityTemporal element
    ...    ${vehicle_expectation_file}
    ...    ${temporal_entity_representation_id}
    ...    ${response.json()}

Setup Initial Entities
    ${temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicule_id_prefix}
    Create Temporal Representation Of Entity    ${vehicle_payload_file}    ${temporal_entity_representation_id}
    Set Suite Variable    ${temporal_entity_representation_id}

Delete Initial Entities
    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
