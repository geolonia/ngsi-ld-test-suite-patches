*** Settings ***
Documentation   Check that you can delete an attribute of a temporal representation of an entity with simple temporal properties
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Delete Attribute From A Temporal Entity

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${filename}=  vehicle-temporal-representation-sample.jsonld    
${status_code}=  204
${attribute_id}=  fuelLevel

*** Test Cases ***                                                                                         DELETEALL          DATASETID
015_01_01_Delete an attribute from a temporal representation of an entity without deleteALL/datasetID      false              ${EMPTY}   
015_01_02_Delete an attribute from a temporal representation of an entity with datasetId                   false              urn:ngsi-ld:Vehicle:12345-fuel
015_01_03_Delete an attribute from a temporal representation of an entity with deleteALL/datasetID         true               urn:ngsi-ld:Vehicle:12345-fuel        

*** Keywords ***
Delete Attribute From A Temporal Entity
    [Arguments]  ${deleteAll}    ${datasetId}
    [Documentation]  Check that you can delete an attribute of a temporal representation of an entity with simple temporal properties
    [Tags]  mandatory

    ${temporal_entity_representation_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${response}=  Create Or Update Temporal Representation Of Entity Selecting Content Type  ${temporal_entity_representation_id}    ${filename}     ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=  Delete Attribute From Temporal Entity  ${temporal_entity_representation_id}    ${attribute_id}     ${CONTENT_TYPE_LD_JSON}    ${datasetId}    ${deleteAll}
    Check Response Status Code   ${status_code}    ${response['status']}

    [Teardown]    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}