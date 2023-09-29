*** Settings ***
Documentation       Check that a notification is only sent if and only if the status is active

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationSubscription.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource
Resource            ${EXECDIR}/resources/NotificationUtils.resource

Suite Setup         Before Test
Suite Teardown      After Test


*** Variables ***
${subscription_id_prefix}=              urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=      subscriptions/subscription-building-entities-active.jsonld
${building_id_prefix}=                  urn:ngsi-ld:Building:
${entity_building_filepath}=            building-simple-attributes-sample.jsonld
${fragment_filename}=                   airQualityLevel-fragment.jsonld
${notification_server_send_url}=        http://${notification_server_host}:${notification_server_port}/notify


*** Test Cases ***
046_01_01 Check that a notification is only sent if status is active
    [Documentation]    Check that a notification is only sent if and only if the status is active
    [Tags]    sub-notification    5_8_6    046_01

    Add Initial Entity
    Sleep    1s

    Setup Initial Subscriptions

    Update Entity Attributes    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}

    ${notification}    ${headers}=    Wait for notification    timeout=${10}

    Should be Equal    ${subscription_id}    ${notification}[subscriptionId]
    Should be Equal    ${entity_id}    ${notification}[data][0][id]
    Should be Equal    ${5}    ${notification}[data][0][airQualityLevel][value]


*** Keywords ***
Setup Initial Subscriptions
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=    Load Subscription Sample With Reachable Endpoint
    ...    ${subscription_payload_file_path}
    ...    ${subscription_id}
    ...    ${notification_server_send_url}
    ${subscription_payload}=    Set Entity Id In Subscription    ${subscription_payload}    ${entity_id}
    Create Subscription From Subscription Payload    ${subscription_payload}    ${CONTENT_TYPE_LD_JSON}
    Set Suite Variable    ${subscription_id}

Delete Initial Subscriptions
    Delete Subscription    ${subscription_id}

Before Test
    Start Local Server    ${notification_server_host}    ${notification_server_port}

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
