*** Settings ***
Documentation   Check that you can delete an attribute instance in temporal representation of an entity 
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${filename}=  vehicle-temporal-representation-sample.jsonld
${attributeId}=  speed

*** Test Cases ***
017_01_Delete an attribute instance in temporal representation of an entity 
    [Documentation]  Check that you can delete an attribute instance in temporal representation of an entity 
    [Tags]  mandatory

    ${temporal_entity_representation_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    Set Suite Variable  ${temporal_entity_representation_id}
    ${response}=  Create Or Update Temporal Representation Of Entity Selecting Content Type  ${temporal_entity_representation_id}    ${filename}     ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=  Get Temporal Representation Of Entity  ${temporal_entity_representation_id}    ${CONTENT_TYPE_LD_JSON}    sysAttrs
    ${instanceId}=  Set Variable  ${response['body']['speed'][0]['instanceId']}

    ${response}=  Delete Attribute Instance From Temporal Entity  ${temporal_entity_representation_id}    ${attributeId}    ${instanceId}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  204    ${response['status']}

    [Teardown]    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}