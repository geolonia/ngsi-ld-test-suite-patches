*** Settings ***
Documentation       A notification with all subscribed Entities will be included if query or geoquery are not defined.

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationSubscription.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource
Resource            ${EXECDIR}/resources/NotificationUtils.resource

Suite Setup         Before Test
Suite Teardown      After Test


*** Variables ***
${subscription_id_prefix}=              urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=      subscriptions/subscription-building-entities-default.jsonld
${building_id_prefix}=                  urn:ngsi-ld:Building:
${notification_server_send_url}=        http://${notification_server_host}:${notification_server_port}/notify
${entity_building_filepath}=            building-simple-attributes-sample.jsonld
${fragment_filename}=                   airQualityLevel-fragment.jsonld


*** Test Cases ***
046_03_01 Check that a notification is sent with all entities
    [Documentation]    A notification with all subscribed Entities will be included if query or geoquery are not defined.
    [Tags]    sub-notification    5_8_6
    ${response}=    Setup Initial Subscriptions

    Update Entity Attributes    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}

    ${notification}    ${headers}=    Wait for notification    ${5}
    Should be Equal    ${subscription_id}    ${notification}[subscriptionId]
    Dictionary Should Contain Key    ${notification}    data
    Should Not Be Empty    ${notification}[data]    Notification data should not be empty
    Should be Equal    ${entity_id}    ${notification}[data][0][id]
    Should be True
    ...    '${notification}[data][0][airQualityLevel][value]'=='5.0' or '${notification}[data][0][airQualityLevel][value]'=='5'
    Should be Equal    Eiffel Tower    ${notification}[data][0][name][value]


*** Keywords ***
Before Test
    Start Local Server    ${notification_server_host}    ${notification_server_port}

Setup Initial Subscriptions
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    ${subscription_payload}=    Load Subscription Sample With Reachable Endpoint
    ...    ${subscription_payload_file_path}
    ...    ${subscription_id}
    ...    ${notification_server_send_url}
    ${subscription_payload}=    Set Entity Id In Subscription    ${subscription_payload}    ${entity_id}
    Set Suite Variable    ${entity_id}
    Set Suite Variable    ${subscription_id}

    Create Entity    ${entity_building_filepath}    ${entity_id}
    Sleep    1s
    Create Subscription From Subscription Payload    ${subscription_payload}    ${CONTENT_TYPE_LD_JSON}
    Sleep    1s

After Test
    Delete Initial Subscriptions
    Delete Initial Entity
    Stop Local Server

Delete Initial Subscriptions
    Delete Subscription    ${subscription_id}

Add Initial Entity
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Create Entity    ${entity_building_filepath}    ${entity_id}
    Set Suite Variable    ${entity_id}

Delete Initial Entity
    Delete Entity by Id    ${entity_id}
