*** Settings ***
Documentation       Check that one cannot delete an attribute instance in temporal representation of an entity if the EntityId/AttributeId/InstanceId is not right

Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Create Temporal Entity
Test Teardown       Delete Temporal Entity
Test Template       Delete attribute instance


*** Variables ***
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:
${filename}=                vehicle-temporal-representation.jsonld
${status_code}=             400


*** Test Cases ***    TEMPORAL_ENTITY_ID    ATTRIBUTE_ID    INSTANCE_ID
017_02_01 Delete an attribute instance in temporal representation of an entity if the entity id is not valid
    invalidId    speed    ${valid_instanceId}
017_02_02 Delete an attribute instance in temporal representation of an entity if the entity id is not present
    ${EMPTY}    speed    ${valid_instanceId}
017_02_03 Delete an attribute instance in temporal representation of an entity if the instance id is not valid
    ${temporal_entity_representation_id}    speed    invalidId
017_02_04 Delete an attribute instance in temporal representation of an entity if the attribute name is not a valid name
    ${temporal_entity_representation_id}    invalid(Name    ${valid_instanceId}
017_02_05 Delete an attribute instance in temporal representation of an entity if the attribute name is not present
    ${temporal_entity_representation_id}    ${EMPTY}    ${valid_instanceId}


*** Keywords ***
Delete attribute instance
    [Documentation]    Check that one cannot delete an attribute instance in temporal representation of an entity if the EntityId/AttributeId/InstanceId is not right
    [Tags]    tea-instance-delete    5_6_15
    [Arguments]    ${temporal_entity_id}    ${attributeId}    ${instanceId}
    ${response}=    Delete Attribute Instance From Temporal Entity
    ...    ${temporal_entity_id}
    ...    ${attributeId}
    ...    ${instanceId}
    ...    ${CONTENT_TYPE_JSON}
    ...    ${ngsild_test_suite_context}
    Check Response Status Code    ${status_code}    ${response.status_code}

Create Temporal Entity
    ${temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    Set Test Variable    ${temporal_entity_representation_id}
    ${response}=    Create Or Update Temporal Representation Of Entity Selecting Content Type
    ...    temporal_entity_representation_id=${temporal_entity_representation_id}
    ...    filename=${filename}
    ...    content_type=${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Retrieve Temporal Representation Of Entity
    ...    ${temporal_entity_representation_id}
    ...    accept=${CONTENT_TYPE_LD_JSON}
    ...    options=sysAttrs
    ...    context=${ngsild_test_suite_context}
    ${valid_instanceId}=    Set Variable    ${response.json()['speed'][0]['instanceId']}
    Set Test Variable    ${valid_instanceId}

Delete Temporal Entity
    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
