*** Settings ***
Documentation     Check that a notification is only sent if and only if the status is active
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Resource          ${EXECDIR}/resources/NotificationUtils.resource
# Suite Setup       Setup Initial Subscriptions
# Suite Teardown    Delete Initial Subscriptions
Suite Setup    Before Test
Suite Teardown    After Test

*** Variable ***
${subscription_id_prefix}=    urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=    subscriptions/subscription-building-entities-active.jsonld
#subscriptions/testsubscription.jsonld 
${building_id_prefix}=    urn:ngsi-ld:Building:
${entity_building_filepath}=    building-simple-attributes-sample.jsonld
#testentity.jsonld
${fragment_filename}=    airQualityLevel-fragment.jsonld
#testfragment.jsonld
${notification_server_send_url}=     http://${send_notification_server_host}:${send_notification_server_port}/notify

*** Keywords ***
Setup Initial Subscriptions
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=    Load Subscription Sample With Reachable Endpoint    ${subscription_payload_file_path}    ${subscription_id}    ${notification_server_send_url}
    # http://ptsv2.com/t/9jkg1-1625063286/post
    Create Subscription From Subscription Payload    ${subscription_payload}    ${CONTENT_TYPE_LD_JSON}
    Set Suite Variable    ${subscription_id}

Delete Initial Subscriptions
    Delete Subscription    ${subscription_id}

Before Test
    Setup Initial Subscriptions
    NotificationUtils.Start Local Server    ${notification_server_host}    ${notification_server_port}

After Test
    Delete Initial Subscriptions
    Stop Local Server

    
*** Test Cases ***
Check that a notification is only sent if status is active
    [Documentation]     Check that a notification is only sent if and only if the status is active
    [Tags]    sub-notification    5_11_7
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix} 
    Create Entity    ${entity_building_filepath}    ${entity_id}
    
    @{expected_notification_data_entities}=    Create List    Building
    
    Update Entity Attributes    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}

    Wait for subscription notification and validate it  ${subscription_id}  ${expected_notification_data_entities}  timeout=${10}    expected_notification_type=Notification