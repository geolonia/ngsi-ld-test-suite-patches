*** Settings ***
Documentation       Check that you can delete an attribute instance in temporal representation of an entity

Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationProvision/ApiUtils.resource
# Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Teardown      Delete Temporal Entity


*** Variables ***
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:
${filename}=                vehicle-temporal-representation-sample.jsonld
${attributeId}=             speed
${expectation_filename}=    vehicle-temporal-representation-delete-speed-instanceid-sample.jsonld


*** Test Cases ***
017_01_01 Delete an attribute instance in temporal representation of an entity
    [Documentation]    Check that you can delete an attribute instance in temporal representation of an entity
    [Tags]    tea-instance-delete    5_6_15
    ${temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    Set Suite Variable    ${temporal_entity_representation_id}
    ${response}=    Create Or Update Temporal Representation Of Entity Selecting Content Type
    ...    temporal_entity_representation_id=${temporal_entity_representation_id}
    ...    filename=${filename}
    ...    content_type=${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Retrieve Temporal Representation Of Entity
    ...    temporal_entity_representation_id=${temporal_entity_representation_id}
    ...    context=${ngsild_test_suite_context}
    ...    accept=${CONTENT_TYPE_LD_JSON}
    ${instanceId}=    Set Variable    ${response.json()['speed'][0]['instanceId']}
    ${response}=    Delete Attribute Instance From Temporal Entity
    ...    ${temporal_entity_representation_id}
    ...    ${attributeId}
    ...    ${instanceId}
    ...    ${CONTENT_TYPE_JSON}
    ...    ${ngsild_test_suite_context}
    Check Response Status Code    204    ${response.status_code}
    ${temporal_entity_expectation_payload}=    Load Test Sample
    ...    temporalEntities/expectations/${expectation_filename}
    ...    ${temporal_entity_representation_id}
    ${response}=    Retrieve Temporal Representation Of Entity
    ...    temporal_entity_representation_id=${temporal_entity_representation_id}
    ...    context=${ngsild_test_suite_context}
    ...    accept=${CONTENT_TYPE_LD_JSON}
    ${ignored_attributes}=    Create List    instanceId    @context
    Check Updated Resource Set To
    ...    ${temporal_entity_expectation_payload}
    ...    ${response.json()}
    ...    ${ignored_attributes}


*** Keywords ***
Delete Temporal Entity
    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
