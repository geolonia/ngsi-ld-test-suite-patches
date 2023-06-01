*** Settings ***
Documentation       Check that you cannot query the temporal evolution of entities with an invalid request or invalid request content

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Setup Initial Entities
Suite Teardown      Delete Initial Entities


*** Variables ***
${vehicule_id_prefix}=      urn:ngsi-ld:Vehicle:
${vehicle_payload_file}=    2020-08-vehicule-temporal-representation-sample.jsonld


*** Test Cases ***
Query the temporal evolution of entities with an invalid request
    [Documentation]    Check that you cannot query the temporal evolution of entities with an invalid request
    [Tags]    te-query    5_7_4
    ${response}=    Query Temporal Representation Of Entities
    ...    timerel=after
    ...    timeAt=2020-07-01T12:05:00Z
    ...    context=${ngsild_test_suite_context}
    Check Response Status Code    400    ${response.status_code}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()}
    ...    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}



*** Keywords ***
Setup Initial Entities
    ${temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicule_id_prefix}
    Create Temporal Representation Of Entity    ${vehicle_payload_file}    ${temporal_entity_representation_id}
    Set Suite Variable    ${temporal_entity_representation_id}

Delete Initial Entities
    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
