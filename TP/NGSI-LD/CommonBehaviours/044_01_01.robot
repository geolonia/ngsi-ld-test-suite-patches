*** Settings ***
Documentation   Verify that PATCH HTTP requests can be done with "application/merge-patch+json" as Content-Type 
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${filename}=  vehicle-two-datasetid-attributes-sample.jsonld
${fragment_filename}=  vehicle-two-datasetid-attributes-sample-01.jsonld

*** Test Cases ***                               
044_01_01_endpoint /entities/{entityId}/attrs/
    [Documentation]  Verify that PATCH HTTP requests can be done with "application/merge-patch+json" as Content-Type 
    [Tags]  mandatory
    ${entity_id}=       Generate Random Entity Id    ${vehicle_id_prefix}    
    ${request}    ${response}=    Create Entity Selecting Content Type    ${filename}    ${entity_id}    ${CONTENT_TYPE_LD_JSON}    
    Check Response Status Code  201    ${response['status']}
    
    ${response}=    Update Entity Attributes    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_MERGE_PATCH_JSON}
    Check Response Status Code  204    ${response['status']}

    [Teardown]  Delete Entity by Id  ${entity_id}