*** Settings ***
Documentation     If a Subscription does not define a timeInterval term, the notification shall be sent whenever there is a change in the watched Attributes. The notification message shall include all the subscribed Entities that changed and that match (as mandated by clauses 4.9 and 4.10) the query and geoquery conditions

Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Resource          ${EXECDIR}/resources/NotificationUtils.resource
Suite Setup       Setup Server And Subscriptions
Suite Teardown    Delete Server And Subscriptions

*** Variable ***
${subscription_id_prefix}=    urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=    subscriptions/subscription-building-entities-active-query.jsonld
${building_id_prefix}=    urn:ngsi-ld:Building:
${building_filename}=    building-location-attribute.jsonld
${notification_server_send_url}=     http://${send_notification_server_host}:${send_notification_server_port}/notify

*** Keywords ***
Setup Server And Subscriptions
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=    Load Subscription Sample With Reachable Endpoint    ${subscription_payload_file_path}    ${subscription_id}    ${notification_server_send_url}
    Create Subscription From Subscription Payload    ${subscription_payload}    ${CONTENT_TYPE_LD_JSON}
    Set Suite Variable    ${subscription_id}
    NotificationUtils.Start Local Server    ${notification_server_host}    ${notification_server_port}
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Suite Variable    ${entity_id}

Delete Server And Subscriptions
    Delete Subscription    ${subscription_id}
    Delete Entity by Id Returning Response    ${entity_id}
    Stop Local Server

*** Test Case ***
Check that a notification is sent with all matching entities
    [Documentation]     only the subscribed Entities matching the query and watched attributes shall be included.
    [Tags]    sub-notification    5_11_7    046_06
    ${entity_building}=    Create Entity Selecting Content Type    ${building_filename}    ${entity_id}    ${CONTENT_TYPE_LD_JSON}

    ${notification}=    Wait for notification    timeout=${10}

    Output  ${notification}
    Should be Equal    ${subscription_id}    ${notification}[subscriptionId]
    Should be Equal    ${entity_id}    ${notification}[data][0][id]





