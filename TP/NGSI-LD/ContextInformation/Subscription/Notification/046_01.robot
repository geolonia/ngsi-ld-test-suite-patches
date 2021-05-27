*** Settings ***
Documentation     Check that a notification is only sent if and only if the status is active
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Resource          ${EXECDIR}/resources/NotificationUtils.resource
Suite Setup       Setup Initial Subscriptions
Suite Teardown    Delete Initial Subscriptions

*** Variable ***
${subscription_id_prefix}=    urn:ngsi-ld:Subscription:
${active_subscription_payload_file_path}=    subscriptions/subscription-building-entities-active.jsonld
${timeinterval_subscription_payload_file_path}= subscriptions/subscription-timeinterval-sample.jsonld
${building_id_prefix}=    urn:ngsi-ld:Building:




*** Test Case ***
Check that a notification is only sent if statis is active
    [Arguments]      ${fragment_filename}    
    [Documentation]     Check that a notification is only sent if and only if the status is active
    [Tags]    sub-notification    5_11_7
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=    Load Subscription Sample With Reachable Endpoint    ${active_subscription_payload_file_path}    ${subscription_id}
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Suite Variable    ${subscription_id}
    Update Entity Attributes    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}
    Wait for notification  timeout=${5}





