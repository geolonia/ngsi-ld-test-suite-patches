*** Settings ***
Documentation       Verify that PATCH HTTP requests can be done with "application/merge-patch+json" as Content-Type

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource


*** Variables ***
${vehicle_id_prefix}=           urn:ngsi-ld:Vehicle:
${vehicle_filename}=            vehicle-simple-attributes-sample.jsonld
${vehicle_fragment}=            vehicle-brandname-fragment.json
${attribute_id}=                brandName
${subscription_id_prefix}=      urn:ngsi-ld:Subscription:
${subscription_filename}=       subscriptions/subscription-sample.jsonld
${subscription_fragment}=       subscriptions/fragments/subscription-update-sample.json


*** Test Cases ***
044_01_01 endpoint /entities/{entityId}/attrs/{attrId}
    [Documentation]    Verify that PATCH HTTP requests can be done with "application/merge-patch+json" as Content-Type
    [Tags]    ea-partial-update    6_3_4
    ${entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    ${response}=    Create Entity Selecting Content Type
    ...    ${vehicle_filename}
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Partial Update Entity Attributes
    ...    ${entity_id}
    ...    ${attribute_id}
    ...    ${vehicle_fragment}
    ...    ${CONTENT_TYPE_MERGE_PATCH_JSON}
    ...    context=${ngsild_test_suite_context}
    Check Response Status Code    204    ${response.status_code}
    [Teardown]    Delete Entity by Id    ${entity_id}

044_01_02 endpoint /subscriptions/{subscriptionId}
    [Documentation]    Verify that PATCH HTTP requests can be done with "application/merge-patch+json" as Content-Type
    [Tags]    sub-update    6_3_4
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${response}=    Create Subscription    ${subscription_id}    ${subscription_filename}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Update Subscription
    ...    ${subscription_id}
    ...    ${subscription_fragment}
    ...    ${CONTENT_TYPE_MERGE_PATCH_JSON}
    ...    context=${ngsild_test_suite_context}
    Check Response Status Code    204    ${response.status_code}
    [Teardown]    Delete Subscription    ${subscription_id}
