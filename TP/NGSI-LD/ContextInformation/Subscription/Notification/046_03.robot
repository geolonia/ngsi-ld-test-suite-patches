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
${subscription_payload_file_path}=    subscriptions/subscription-timeInterval-sample.jsonld
${building_id_prefix}=    urn:ngsi-ld:Building:
${expected_notification_data_entities}=    TODO

*** Test Case ***
Check that a notification is sent with all entities
    [Documentation]     A notification with all all subscribed Entities will be included if query or geoquery are not defined.
    [Tags]    sub-notification    5_11_7
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=    Load Subscription Sample With Reachable Endpoint    ${subscription_payload_file_path}    ${subscription_id}
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Suite Variable    ${subscription_id}
    Wait for subscription notification and validate it  ${subscription_id}  ${expected_notification_data_entities}  timeout=${5}

*** Keywords ***
Setup Initial Subscriptions
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    Create Subscription    ${subscription_id}    ${subscription_payload_file_path}    ${CONTENT_TYPE_LD_JSON}
    Set Suite Variable    ${subscription_id}

Delete Initial Subscriptions
    Delete Subscription    ${subscription_id}




