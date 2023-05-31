*** Settings ***
Documentation       Check that you cannot delete an attribute instance in temporal representation of an entity if the EntityId/AttributeId/InstanceId is not right

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Create Temporal Entity
Suite Teardown      Delete Temporal Entity
Test Template       Delete attribute instance


*** Variables ***
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:
${filename}=                vehicle-temporal-representation-sample.jsonld
${status_code}=             400


*** Test Cases ***    TEMPORAL_ENTITY_ID    ATTRIBUTE_ID    INSTANCE_ID
017_02_01_delete an attribute instance in temporal representation of an entity if the entity id is not valid
    invalidId    speed    ${valid_instanceId}
017_02_02_delete an attribute instance in temporal representation of an entity if the entity id is not present
    ${EMPTY}    speed    ${valid_instanceId}
017_02_03_delete an attribute instance in temporal representation of an entity if the instance id is not valid
    ${temporal_entity_representation_id}    speed    invalidId
017_02_04_delete an attribute instance in temporal representation of an entity if the attribute name is not a valid name
    ${temporal_entity_representation_id}    invalid(Name    ${valid_instanceId}
017_02_05_delete an attribute instance in temporal representation of an entity if the attribute name is not present
    ${temporal_entity_representation_id}    ${EMPTY}    ${valid_instanceId}


*** Keywords ***
Delete attribute instance
    [Documentation]    Check that you cannot delete an attribute instance in temporal representation of an entity if the EntityId/AttributeId/InstanceId is not right
    [Tags]    tea-instance-delete    5_6_15
    [Arguments]    ${temporal_entity_id}    ${attributeId}    ${instanceId}
    ${response}=    Delete Attribute Instance From Temporal Entity
    ...    ${temporal_entity_id}
    ...    ${attributeId}
    ...    ${instanceId}
    ...    ${CONTENT_TYPE_JSON}
    ...    ${ngsild_test_suite_context}
    Check Response Status Code    ${status_code}    ${response['status']}

Create Temporal Entity
    ${temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    Set Suite Variable    ${temporal_entity_representation_id}
    ${response}=    Create Or Update Temporal Representation Of Entity Selecting Content Type
    ...    ${temporal_entity_representation_id}
    ...    ${filename}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response['status']}
    ${response}=    Get Temporal Representation Of Entity
    ...    ${temporal_entity_representation_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    ...    sysAttrs
    ...    ${ngsild_test_suite_context}
    ${valid_instanceId}=    Set Variable    ${response['body']['speed'][0]['instanceId']}
    Set Suite Variable    ${valid_instanceId}

Delete Temporal Entity
    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
