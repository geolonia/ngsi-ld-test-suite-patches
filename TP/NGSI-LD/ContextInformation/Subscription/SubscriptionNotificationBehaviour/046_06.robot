*** Settings ***
Documentation       If a Subscription does not define a timeInterval member, the notification shall be sent whenever an entity matches the query defined in the subscription. The notification message shall include all the subscribed Entities that changed and that match (as mandated by clauses 4.9 and 4.10) the query and geoquery conditions

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationSubscription.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource
Resource            ${EXECDIR}/resources/NotificationUtils.resource

Suite Setup         Setup Server And Subscriptions
Suite Teardown      Delete Server And Subscriptions


*** Variables ***
${subscription_id_prefix}=              urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=      subscriptions/subscription-building-entities-active-query.jsonld
${building_id_prefix}=                  urn:ngsi-ld:Building:
${building_filename}=                   building-location-attribute.jsonld
${notification_server_send_url}=        http://${notification_server_host}:${notification_server_port}/notify


*** Test Cases ***
046_06_01 Check that a notification is sent with all matching entities
    [Documentation]    only the subscribed Entities matching the query and watched attributes shall be included.
    [Tags]    sub-notification    5_8_6    046_06
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Suite Variable    ${entity_id}

    ${response}=    Create Entity Selecting Content Type
    ...    ${building_filename}
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}

    ${notification}    ${headers}=    Wait for notification    timeout=${10}
    Should be Equal    ${subscription_id}    ${notification}[subscriptionId]
    Should be Equal    ${entity_id}    ${notification}[data][0][id]


*** Keywords ***
Setup Server And Subscriptions
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=    Load Subscription Sample With Reachable Endpoint
    ...    ${subscription_payload_file_path}
    ...    ${subscription_id}
    ...    ${notification_server_send_url}
    Set Suite Variable    ${subscription_id}
    Start Local Server    ${notification_server_host}    ${notification_server_port}

    Create Subscription From Subscription Payload    ${subscription_payload}    ${CONTENT_TYPE_LD_JSON}
    Sleep    1s

Delete Server And Subscriptions
    Delete Subscription    ${subscription_id}
    Delete Entity by Id    ${entity_id}
    Stop Local Server
