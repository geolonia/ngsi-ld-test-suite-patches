*** Settings ***
Documentation   Verify that PATCH HTTP requests can be done with "application/merge-patch+json" as Content-Type 
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${subscription_id_prefix}=  urn:ngsi-ld:Subscription:
${filename_path}=  csourceSubscriptions/subscription-sample.jsonld
${fragment_filename_path}=  csourceSubscriptions/fragments/subscription-update-sample.jsonld

*** Test Cases ***                               
044_01_03_endpoint /subscriptions/{subscriptionId}       
    [Documentation]  Verify that PATCH HTTP requests can be done with "application/merge-patch+json" as Content-Type 
    [Tags]  mandatory
    ${subscription_id}=       Generate Random Entity Id    ${subscription_id_prefix}    
    ${response}=    Create Subscription    ${subscription_id}    ${filename_path}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Update Subscription    ${subscription_id}     ${fragment_filename_path}    ${CONTENT_TYPE_MERGE_PATCH_JSON}
    Check Response Status Code  204    ${response['status']}

    [Teardown]  Delete Subscription  ${subscription_id}