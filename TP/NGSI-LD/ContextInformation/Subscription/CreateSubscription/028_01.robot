*** Settings ***
Documentation     Check that you can create a subscription
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${subscription_id_prefix}=    urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=    subscriptions/subscription-sample.jsonld

*** Test Cases ***
Create Subscription
    [Documentation]    Check that you can create a subscription
    [Tags]    sub-create    5_8_1
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    Create Subscription    ${subscription_id}    ${subscription_payload_file_path}    ${CONTENT_TYPE_LD_JSON}
    ${created_subscription}=    Load Test Sample    ${subscription_payload_file_path}    ${subscription_id}
    Retrieve Subscription    ${subscription_id}    accept=${CONTENT_TYPE_LD_JSON}   context=${ngsild_test_suite_context}
    Check Created Resource Set To    ${created_subscription}
    [Teardown]    Delete Subscription    ${subscription_id}
