*** Settings ***
Documentation     Check that a notification is only sent if and only if the status is active
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Resource          ${EXECDIR}/resources/NotificationUtils.resource
Suite Setup       Before Test
Suite Teardown    After Test

*** Variable ***
${subscription_id_prefix}=    urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=    subscriptions/subscription-building-entities-active.jsonld
${building_id_prefix}=    urn:ngsi-ld:Building:
${notification_server_send_url}=     http://${send_notification_server_host}:${send_notification_server_port}/notify
${entity_building_filepath}=    building-simple-attributes-sample.jsonld
${fragment_filename}=    airQualityLevel-fragment.jsonld

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

Delete Fixture Data
    Delete Initial Subscriptions
    Delete Initial Entity

Before Test
    NotificationUtils.Start Local Server    ${notification_server_host}    ${notification_server_port}

After Test
    Stop Local Server


*** Test Case ***
Check that a notification is sent with all attributes
    [Documentation]     The structure of the notification message shall be as mandated by clause 5.3.1. The absence of the notification.attributes member of a Subscription means that all Entity Attributes shall be included.     All attributes are included
    [Tags]    sub-notification    5_8_6    046_08_01
    
    Add Initial Entity
    Sleep   1s
    Setup Initial Subscriptions
    
    Update Entity Attributes    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}
    
    ${notification}=    Wait for notification    ${5}
    Output     ${notification}

    Should be Equal    ${subscription_id}    ${notification}[subscriptionId]
    Dictionary Should Contain Key    ${notification}    data
    Should Not Be Empty    ${notification}[data]    Notification data should not be empty
    Should be Equal    ${entity_id}    ${notification}[data][0][id]
    Should be Equal    Eiffel Tower    ${notification}[data][0][name][value]
    Dictionary Should Contain Key    ${notification}[data][0]    almostFull
    Dictionary Should Contain Key    ${notification}[data][0]    airQualityLevel
    Dictionary Should Contain Key    ${notification}[data][0]    subCategory
    [Teardown]  Delete Fixture Data

Check that a notification is sent with all attributes in simplified format
    [Documentation]     The structure of the notification message shall be as mandated by clause 5.3.1. The absence of the notification.attributes member of a Subscription means that all Entity Attributes shall be included    If the notification.format member value is "keyValues" then a simplified representation of the entities (as mandated by clause 4.5.3) shall be provided
    [Tags]    sub-notification    5_8_6    046_08_02
    
    Add Initial Entity
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=    Load Subscription Sample With Reachable Endpoint    ${subscription_payload_file_path}    ${subscription_id}    ${notification_server_send_url}
    ${subscription_payload}=    Update Value To Json    ${subscription_payload}     $..notification['format']    keyValues
    ${subscription_payload}=    Set Entity Id In Subscription    ${subscription_payload}    ${entity_id}
    Create Subscription From Subscription Payload    ${subscription_payload}    ${CONTENT_TYPE_LD_JSON}
    Set Suite Variable    ${subscription_id}
    
    Update Entity Attributes    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}

    ${notification}=    Wait for notification    ${5}
    Output     ${notification}

    Should be Equal    ${subscription_id}    ${notification}[subscriptionId]
    Dictionary Should Contain Key    ${notification}    data
    Should Not Be Empty    ${notification}[data]    Notification data should not be empty
    Should Be Equal    ${entity_id}     ${notification}[data][0][id]
    Should be Equal    Eiffel Tower     ${notification}[data][0][name]
    [Teardown]  Delete Fixture Data

    






