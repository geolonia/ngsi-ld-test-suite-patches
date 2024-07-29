*** Settings ***
Documentation       If a Subscription defines a throttling member, a Notification shall not be sent if the throttling specified (in seconds) has not elapsed yet.

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationSubscription.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource
Resource            ${EXECDIR}/resources/NotificationUtils.resource

Suite Setup         Before Test
Suite Teardown      After Test


*** Variables ***
${subscription_id_prefix}=              urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=      subscriptions/subscription-valid-throttling.jsonld
${building_id_prefix}=                  urn:ngsi-ld:Building:
${notification_server_send_url}=        http://${notification_server_host}:${notification_server_port}/notify
${entity_building_filepath}=            building-simple-attributes.jsonld
${fragment_filename}=                   airQualityLevel-fragment.jsonld


*** Test Cases ***
046_15_01 Check that a notification is not sent if the throttling has not elapsed yet
    [Documentation]    If a Subscription defines a throttling member, a Notification shall not be sent if the throttling specified (in seconds) has not elapsed yet.
    [Tags]    sub-notification    5_8_6

    ${response}=    Update Entity Attributes    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}

    ${notification}    ${headers}=    Wait for notification    timeout=${10}

    ${response}=    Update Entity Attributes    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}

    Wait for no notification


*** Keywords ***
Before Test
    Start Local Server    ${notification_server_host}    ${notification_server_port}
    Setup Initial Subscriptions

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

    ${create_response1}=    Create Entity    ${entity_building_filepath}    ${entity_id}
    Check Response Status Code    201    ${create_response1.status_code}
    Sleep    1s
    ${create_response2}=    Create Subscription From Subscription Payload
    ...    ${subscription_payload}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${create_response2.status_code}
    Sleep    1s

After Test
    Delete Initial Subscriptions
    Delete Initial Entity
    Stop Local Server

Delete Initial Subscriptions
    Delete Subscription    ${subscription_id}

Delete Initial Entity
    Delete Entity by Id    ${entity_id}
