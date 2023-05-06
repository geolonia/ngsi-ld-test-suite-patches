*** Settings ***
Documentation       Check that you cannot delete an attribute instance in temporal representation of an entity if the EntityId/AttributeId/InstanceId is not right

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Create Id
Test Teardown       Delete Intitial Temporal Representation Of Entity
Test Template       Delete Attribute Instance


*** Variables ***
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:
${filename}=                vehicle-temporal-representation-sample.jsonld
${status_code}=             404


*** Test Cases ***    TEMPORAL_ENTITY_ID    ATTRIBUTE_ID    INSTANCE_ID
017_03_01_delete an attribute instance in temporal representation of an entity if the entity with given id is not found
    ${unknown_temporal_entity_id}    speed    ${valid_instanceId}
017_03_02_delete an attribute instance in temporal representation of an entity if the target attribute is not found
    ${temporal_entity_representation_id}    speed2    ${valid_instanceId}
017_03_03_delete an attribute instance in temporal representation of an entity if the target attribute instance is not found
    ${temporal_entity_representation_id}    speed    urn:ngsi-ld:01234567890123456789


*** Keywords ***
Delete Attribute Instance
    [Documentation]    Check that you cannot delete an attribute instance in temporal representation of an entity if the EntityId/AttributeId/InstanceId is not found
    [Tags]    tea-instance-delete    5_6_15
    [Arguments]    ${temporal_entity_id}    ${attributeId}    ${instanceId}
    ${response}=    Delete Attribute Instance From Temporal Entity
    ...    ${temporal_entity_id}
    ...    ${attributeId}
    ...    ${instanceId}
    ...    ${CONTENT_TYPE_JSON}
    ...    ${ngsild_test_suite_context}
    Check Response Status Code    ${status_code}    ${response.status_code}

Create Id
    ${temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    Set Test Variable    ${temporal_entity_representation_id}
    ${response}=    Create Or Update Temporal Representation Of Entity Selecting Content Type
    ...    ${temporal_entity_representation_id}
    ...    ${filename}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${unknown_temporal_entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    Set Test Variable    ${unknown_temporal_entity_id}
    ${response}=    Get Temporal Representation Of Entity
    ...    ${temporal_entity_representation_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    ...    sysAttrs
    ...    ${ngsild_test_suite_context}
    ${valid_instanceId}=    Set Variable    ${response.json()['speed'][0]['instanceId']}
    Set Test Variable    ${valid_instanceId}

Delete Intitial Temporal Representation Of Entity
    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
