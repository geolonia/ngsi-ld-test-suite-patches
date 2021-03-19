*** Settings ***
Documentation   Check that you cannot delete an attribute instance in temporal representation of an entity if the entityId/attributeId/instanceId is not right
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Suite Setup    Create Id
Test Template  Delete attribute instance

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${filename}=  vehicle-temporal-representation-sample.jsonld
${status_code}=  400

*** Test Cases ***                                                                                                              TEMPORAL_ENTITY_ID                          ATTRIBUTE_ID               INSTANCE_ID                                               
017_02_01_delete an attribute instance in temporal representation of an entity if the entity id is not valid                    invalidId                                   speed                      ${valid_instanceId}
017_02_02_delete an attribute instance in temporal representation of an entity if the entity id is not present                  ${EMPTY}                                    speed                      ${valid_instanceId}
017_02_03_delete an attribute instance in temporal representation of an entity if the instance id is not valid                  ${temporal_entity_representation_id}        speed                      invalidId                       
017_02_04_delete an attribute instance in temporal representation of an entity if the instance id is not present                ${temporal_entity_representation_id}        speed                      ${EMPTY}                   
017_02_05_delete an attribute instance in temporal representation of an entity if the attribute name is not a valid name        ${temporal_entity_representation_id}        invalidId                  ${valid_instanceId}
017_02_06_delete an attribute instance in temporal representation of an entity if the attribute name is not present             ${temporal_entity_representation_id}        ${EMPTY}                   ${valid_instanceId}

*** Keywords ***
Delete attribute instance
    [Arguments]  ${temporal_entity_id}    ${attributeId}    ${instanceId}
    [Documentation]  Check that you cannot delete an attribute instance in temporal representation of an entity if the entityId/attributeId/instanceId is not right
    [Tags]  mandatory

    ${response}=  Delete Attribute Instance From Temporal Entity  ${temporal_entity_id}    ${attributeId}    ${instanceId}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  ${status_code}    ${response['status']}

    [Teardown]    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}

Create Id
    ${temporal_entity_representation_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    Set Suite Variable  ${temporal_entity_representation_id}
    ${response}=  Create Or Update Temporal Representation Of Entity Selecting Content Type  ${temporal_entity_representation_id}    ${filename}     ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=  Get Temporal Representation Of Entity  ${temporal_entity_representation_id}    ${CONTENT_TYPE_LD_JSON}    sysAttrs
    ${valid_instanceId}=  Set Variable  ${response['body']['speed'][0]['instanceId']}
    Set Suite Variable  ${valid_instanceId}