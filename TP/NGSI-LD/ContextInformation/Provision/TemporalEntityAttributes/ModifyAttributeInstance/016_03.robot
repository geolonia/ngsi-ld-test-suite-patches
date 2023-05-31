*** Settings ***
Documentation       Check that you cannot modify an attribute instance in temporal representation of an entity if the EntityId/AttributeId/InstanceId is not right

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Create Id
Suite Teardown      Delete Temporal Entity
Test Template       Modify Attribute Instance Temporal Entity


*** Variables ***
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:
${filename}=                vehicle-temporal-representation-sample.jsonld
${fragment_filename}=       vehicle-temporal-modify-attribute-instance-fragment.jsonld
${status_code}=             404


*** Test Cases ***    TEMPORAL_ENTITY_ID    ATTRIBUTE_ID    INSTANCE_ID
016_03_01_modify attribute instance in temporal representation of an entity if the entity with given id is not found
    ${unknown_temporal_entity_id}    speed    ${valid_instanceId}
016_03_02_modify attribute instance in temporal representation of an entity if the target attribute is not found
    ${temporal_entity_representation_id}    speed2    ${valid_instanceId}
016_03_03_modify attribute instance in temporal representation of an entity if the target attribute instance is not found
    ${temporal_entity_representation_id}    speed    urn:ngsi-ld:01234567890123456789


*** Keywords ***
Modify Attribute Instance Temporal Entity
    [Documentation]    Check that you cannot partially modify attribute instance in temporal representation of an entity if the EntityId/AttributeId/InstanceId is not found
    [Tags]    tea-partial-update    5_6_14
    [Arguments]    ${temporal_entity_id}    ${attributeId}    ${instanceId}
    ${response}=    Modify Attribute Instance From Temporal Entity
    ...    ${temporal_entity_id}
    ...    ${attributeId}
    ...    ${instanceId}
    ...    ${fragment_filename}
    ...    ${CONTENT_TYPE_JSON}
    ...    ${ngsild_test_suite_context}
    Check Response Status Code    ${status_code}    ${response['status']}

Create Id
    ${temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    Set Suite Variable    ${temporal_entity_representation_id}
    ${response}=    Create Or Update Temporal Representation Of Entity Selecting Content Type
    ...    ${temporal_entity_representation_id}
    ...    ${filename}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response['status']}
    ${unknown_temporal_entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    Set Suite Variable    ${unknown_temporal_entity_id}
    ${response}=    Get Temporal Representation Of Entity
    ...    ${temporal_entity_representation_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    ...    sysAttrs
    ...    ${ngsild_test_suite_context}
    ${valid_instanceId}=    Set Variable    ${response['body']['speed'][0]['instanceId']}
    Set Suite Variable    ${valid_instanceId}

Delete Temporal Entity
    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
