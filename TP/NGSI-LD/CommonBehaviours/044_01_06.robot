*** Settings ***
Documentation   Verify that PATCH HTTP requests can be done with "application/merge-patch+json" as Content-Type 
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${temporal_entity_filename}=  vehicle-temporal-representation-sample.jsonld
${temporal_entity_fragment_file_path}=  vehicle-temporal-representation-fragment.jsonld
${attribute_id}=  speed

*** Test Cases ***                               
044_01_06_endpoint /temporal/entities/{entityId}/attrs/{attrId}/{instanceId} 
    [Documentation]  Verify that PATCH HTTP requests can be done with "application/merge-patch+json" as Content-Type 
    [Tags]  mandatory
    ${temporal_entity_id}=   Generate Random Entity Id    ${vehicle_id_prefix}
    ${response}=  Create Temporal Representation Of Entity Selecting Content Type  ${temporal_entity_id}    ${temporal_entity_filename}     ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=  Get Temporal Representation Of Entity  ${temporal_entity_id}    ${CONTENT_TYPE_LD_JSON}
    ${instance_id}=  Set Variable  ${response["body"]["speed"][0]["instanceId"]}
    
    ${response}=  Update Temporal Representation Of Entity Selecting Content Type  ${temporal_entity_id}    ${attribute_id}    ${instance_id}    ${temporal_entity_fragment_file_path}     ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  204    ${response['status']}

    [Teardown]  Delete Temporal Representation Of Entity    ${temporal_entity_id}