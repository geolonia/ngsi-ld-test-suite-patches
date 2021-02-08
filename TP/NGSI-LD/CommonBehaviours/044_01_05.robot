*** Settings ***
Documentation   Verify that PATCH HTTP requests can be done with "application/merge-patch+json" as Content-Type 
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${subscription_id_prefix}=  urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=   csourceSubscriptions/subscription-sample.jsonld
${subscription_update_fragment_file_path}=   csourceSubscriptions/fragments/subscription-update-sample.json

*** Test Cases ***                               
044_01_05_endpoint /csourceSubscriptions/{subscriptionId}
    [Documentation]  Verify that PATCH HTTP requests can be done with "application/merge-patch+json" as Content-Type 
    [Tags]  mandatory
    ${subscription_id}=   Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=  Load Test Sample    ${subscription_payload_file_path}    ${subscription_id}
    Create Context Source Registration Subscription  ${subscription_payload}
    Check Response Status Code Set To  201

    ${subscription_update_fragment}=    Load Test Sample    ${subscription_update_fragment_file_path}
    ${response}=    Update Context Source Registration Subscription By Selecting Content Type  ${subscription_id}     ${subscription_update_fragment}    ${CONTENT_TYPE_MERGE_PATCH_JSON}
    Check Response Status Code  204    ${response['status']}

    [Teardown]  Delete Context Source Registration Subscription  ${subscription_id}