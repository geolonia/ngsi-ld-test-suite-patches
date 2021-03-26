*** Settings ***
Documentation   Check that you cannot partially update an attribute instance in temporal representation of an entity if the entityId/attributeId/instanceId is not right
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Suite Setup    Create Id
Test Template  Partially Update Temporal Entity

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${filename}=  vehicle-temporal-representation-sample.jsonld
${fragment_filename}=  vehicle-temporal-instanceid-update-fragment.jsonld
${status_code}=  404

*** Test Cases ***                                                                                                               TEMPORAL_ENTITY_ID                          ATTRIBUTE_ID               INSTANCE_ID                                               
016_03_01_update an attribute instance in temporal representation of an entity if the entity with given id is not found          ${unknown_temporal_entity_id}               speed                      ${valid_instanceId}
016_03_02_update an attribute instance in temporal representation of an entity if the target attribute is not found              ${temporal_entity_representation_id}        speed2                     ${valid_instanceId}
016_03_03_update an attribute instance in temporal representation of an entity if the target attribute instance is not found     ${temporal_entity_representation_id}        speed                      urn:ngsi-ld:01234567890123456789

*** Keywords ***
Partially Update Temporal Entity
    [Arguments]  ${temporal_entity_id}    ${attributeId}    ${instanceId}
    [Documentation]  Check that you cannot partially update an attribute instance in temporal representation of an entity if the entity/attribute/instance id is not found
    [Tags]  tea-partial-update

    ${response}=  Partial Update Attribute From Temporal Entity  ${temporal_entity_id}    ${attributeId}    ${instanceId}    ${fragment_filename}    ${CONTENT_TYPE_JSON}   ${ngsild_test_suite_context}
    Check Response Status Code  ${status_code}    ${response['status']}

    [Teardown]    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}

Create Id
    ${temporal_entity_representation_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    Set Suite Variable  ${temporal_entity_representation_id}
    ${response}=  Create Or Update Temporal Representation Of Entity Selecting Content Type  ${temporal_entity_representation_id}    ${filename}     ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}
    ${unknown_temporal_entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    Set Suite Variable  ${unknown_temporal_entity_id}

    ${response}=  Get Temporal Representation Of Entity  ${temporal_entity_representation_id}    ${CONTENT_TYPE_LD_JSON}    sysAttrs    ${ngsild_test_suite_context}
    ${valid_instanceId}=  Set Variable  ${response['body']['speed'][0]['instanceId']}
    Set Suite Variable  ${valid_instanceId}