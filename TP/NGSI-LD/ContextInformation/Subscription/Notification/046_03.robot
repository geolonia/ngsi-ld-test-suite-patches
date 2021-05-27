*** Settings ***
Documentation     A notification with all all subscribed Entities will be included if query or geoquery are not defined.
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Resource          ${EXECDIR}/resources/NotificationUtils.resource
Suite Setup       Setup Initial Subscriptions
Suite Teardown    Delete Initial Subscriptions

*** Variable ***
${subscription_id_prefix}=    urn:ngsi-ld:Subscription:
${timeinterval_subscription_payload_file_path}= subscriptions/subscription-timeinterval-sample.jsonld
${building_id_prefix}=    urn:ngsi-ld:Building:




*** Test Case ***
Check that a notification is send with all entities
    [Arguments]      ${fragment_filename}    
    [Documentation]     A notification with all all subscribed Entities will be included if query or geoquery are not defined.
    [Tags]    sub-notification    5_11_7
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=    Load Subscription Sample With Reachable Endpoint    ${timeinterval_subscription_payload_file_path}    ${subscription_id}
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Suite Variable    ${subscription_id}
    Wait for notification  timeout=${15}





