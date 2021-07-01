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
    Create Subscription From Subscription Payload    ${subscription_payload}    ${CONTENT_TYPE_LD_JSON}
    Set Suite Variable    ${subscription_id}

Delete Initial Subscriptions
    Delete Subscription    ${subscription_id}

Before Test
    Setup Initial Subscriptions
    Add Initial Entity
    NotificationUtils.Start Local Server    ${notification_server_host}    ${notification_server_port}

After Test
    Delete Initial Subscriptions
    Delete Initial Entity
    Stop Local Server

Add Initial Entity
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix} 
    Create Entity    ${entity_building_filepath}    ${entity_id}
    Set Suite Variable    ${entity_id}

Delete Initial Entity
    Delete Entity by Id    ${entity_id}

    
*** Test Cases ***
Check that a notification is only sent if status is active
    [Documentation]     Check that a notification is only sent if and only if the status is active
    [Tags]    sub-notification    5_11_7

    Update Entity Attributes    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}

    ${notification}=    Wait for notification    timeout=${5}

    Should be Equal    ${subscription_id}    ${notification}[subscriptionId]
    Should be Equal    ${entity_id}    ${notification}[data][0][id]
    Should be Equal    5    ${notification}[data][0][https://ngsi-ld-test-suite/context#airQualityLevel][value]    
