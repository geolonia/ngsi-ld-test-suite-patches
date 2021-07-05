*** Settings ***
Documentation     A notification with all all subscribed Entities will be included if query or geoquery are not defined.
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Resource          ${EXECDIR}/resources/NotificationUtils.resource
Suite Setup    Before Test
Suite Teardown    After Test

*** Variable ***
${subscription_id_prefix}=    urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=    subscriptions/subscription-timeInterval-sample.jsonld
${building_id_prefix}=    urn:ngsi-ld:Building:
${notification_server_send_url}=     http://${send_notification_server_host}:${send_notification_server_port}/notify
${entity_building_filepath}=    building-simple-attributes-sample.jsonld

*** Keywords ***
Setup Initial Subscriptions
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=    Load Subscription Sample With Reachable Endpoint    ${subscription_payload_file_path}    ${subscription_id}    ${notification_server_send_url}
    ${subscription_payload}=    Set Entity Id In Subscription    ${subscription_payload}    ${entity_id}
    Create Subscription From Subscription Payload    ${subscription_payload}    ${CONTENT_TYPE_LD_JSON}
    Set Suite Variable    ${subscription_id}

Delete Initial Subscriptions
    Delete Subscription    ${subscription_id}

Add Initial Entity
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix} 
    Create Entity    ${entity_building_filepath}    ${entity_id}
    Set Suite Variable    ${entity_id}

Delete Initial Entity
    Delete Entity by Id    ${entity_id}

Before Test
    NotificationUtils.Start Local Server    ${notification_server_host}    ${notification_server_port}

After Test
    Delete Initial Subscriptions
    Delete Initial Entity
    Stop Local Server

*** Test Case ***
Check that a notification is sent with all entities
    [Documentation]     A notification with all all subscribed Entities will be included if query or geoquery are not defined.
    [Tags]    sub-notification    5_11_7
    
    Add Initial Entity
    Setup Initial Subscriptions
    
    ${notification}=    Wait for notification    ${5}
    Output     ${notification}
    Should be Equal    ${subscription_id}    ${notification}[subscriptionId]
    Dictionary Should Contain Key    ${notification}    data
    Should Not Be Empty    ${notification}[data]    Notification data should not be empty
    Should be Equal    ${entity_id}    ${notification}[data][0][id]
    Should be True    '${notification}[data][0][https://ngsi-ld-test-suite/context#airQualityLevel][value]'=='4.0' or '${notification}[data][0][https://ngsi-ld-test-suite/context#airQualityLevel][value]'=='4'
    Should be Equal    Building1    ${notification}[data][0][name][value]



