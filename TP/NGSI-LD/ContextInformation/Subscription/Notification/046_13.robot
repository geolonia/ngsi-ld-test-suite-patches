*** Settings ***
Documentation     The notification.lastNotification member shall be updated with a timestamp representing the current date and time. This test will check the format.

Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Resource          ${EXECDIR}/resources/NotificationUtils.resource


Suite Setup       Setup Initial Subscriptions
Suite Teardown    Delete Initial Subscriptions

*** Variable ***
${subscription_id_prefix}=    urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=    subscriptions/subscription-building-entities-active.jsonld
${building_id_prefix}=    urn:ngsi-ld:Building:




*** Keywords ***
Check that a notification is only sent if statis is active
    [Arguments]      ${fragment_filename}    
    [Documentation]     The notification.lastNotification member shall be updated with a timestamp representing the current date and time. This test will check the format.
    [Tags]    sub-notification    5_11_7
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=    Load Subscription Sample With Reachable Endpoint   ${subscription_payload_file_path}    ${subscription_id}
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}

    @{expected_notification_data_entities}=    Create List    Building
    Set Suite Variable    ${subscription_id}
    Create Subscription  ${subscription_id}  ${subscription_payload}  
    Update Entity Attributes    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}

    Wait for redirected request

    @{expected_notification_additional_members}=    Create List    lastNotification    lastSuccess
    Check NotificationParams    ${notification_expectation_file_path}    ${expected_notification_additional_members}
    

*** Keywords ***
Setup Initial Subscription
    Start Local Server
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=    Load Test Sample    ${subscription_payload_file_path}    ${subscription_id}
    Create Subscription  ${subscription_id}  ${subscription_payload}  
    Set Suite Variable    ${subscription_id}

Delete Subscription
    Stop Local Server
    Delete Subscription      ${subscription_id}


