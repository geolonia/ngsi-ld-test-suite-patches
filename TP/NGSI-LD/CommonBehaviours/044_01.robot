*** Settings ***
Documentation   Verify that PATCH HTTP requests can be done with "application/merge-patch+json" as Content-Type 
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${vehicle_filename}=  vehicle-simple-attributes-sample.jsonld
${vehicle_fragment}=  vehicle-brandname-fragment.jsonld
${attribute_id}=  brandName

${subscription_id_prefix}=  urn:ngsi-ld:Subscription:
${subscription_filename}=  csourceSubscriptions/subscription-sample.jsonld
${subscription_fragment}=  csourceSubscriptions/fragments/subscription-update-sample.jsonld

*** Test Cases ***                               
044_01_01_endpoint /entities/{entityId}/attrs/{attrId}
    [Documentation]  Verify that PATCH HTTP requests can be done with "application/merge-patch+json" as Content-Type 
    [Tags]  cb
    ${entity_id}=       Generate Random Entity Id    ${vehicle_id_prefix}    
    ${request}    ${response}=    Create Entity Selecting Content Type    ${vehicle_filename}    ${entity_id}    ${CONTENT_TYPE_LD_JSON}    
    Check Response Status Code  201    ${response['status']}

    ${response}=    Partial Update Entity Attributes    ${entity_id}    ${attribute_id}    ${vehicle_fragment}    ${CONTENT_TYPE_MERGE_PATCH_JSON}
    Check Response Status Code  204    ${response['status']}

    [Teardown]  Delete Entity by Id  ${entity_id}
 
044_01_02_endpoint /subscriptions/{subscriptionId}       
    [Documentation]  Verify that PATCH HTTP requests can be done with "application/merge-patch+json" as Content-Type 
    [Tags]  cb
    ${subscription_id}=       Generate Random Entity Id    ${subscription_id_prefix}    
    ${response}=    Create Subscription    ${subscription_id}    ${subscription_filename}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Update Subscription    ${subscription_id}     ${subscription_fragment}    ${CONTENT_TYPE_MERGE_PATCH_JSON}
    Check Response Status Code  204    ${response['status']}

    [Teardown]  Delete Subscription  ${subscription_id}

