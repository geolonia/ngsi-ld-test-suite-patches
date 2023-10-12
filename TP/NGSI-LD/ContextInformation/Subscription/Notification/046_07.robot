*** Settings ***
Documentation       Check that a notification is only sent if and only if the status is active

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource
Resource            ${EXECDIR}/resources/NotificationUtils.resource

Suite Setup         Before Test
Suite Teardown      After Test


*** Variables ***
${subscription_id_prefix}                               urn:ngsi-ld:Subscription:
${subscription_payload_file_path}                       subscriptions/subscription-building-entities-active.jsonld
${subscription_payload_file_path_watchedAttributes}     subscriptions/subscription-building-entities-active-watchedAttributes.jsonld
${subscription_payload_file_path_default_context}       subscriptions/subscription-building-entities-active-default-context.jsonld
${building_id_prefix}                                   urn:ngsi-ld:Building:
${notification_server_send_url}                         http://${send_notification_server_host}:${send_notification_server_port}/notify
${entity_building_filepath}                             building-simple-attributes-sample.jsonld
${fragment_filename}                                    airQualityLevel-fragment.jsonld
${date_format}                                          %Y-%m-%dT%H:%M:%SZ
${date_format_with_millis}                              %Y-%m-%dT%H:%M:%S.%fZ


*** Test Cases ***
046_07_01 Check notification structure
    [Documentation]    The structure of the notification message shall be as mandated by clause 5.3. Valid notification with attributes as stated above
    [Tags]    sub-notification    5_8_6    046_07_01
    Add Initial Entity
    Sleep    1s
    Setup Initial Subscriptions
    Update Entity Attributes    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}

    ${notification}=    Wait for notification
    Should Be Equal    ${notification}[type]    Notification
    Should Be Equal    ${notification}[subscriptionId]    ${subscription_id}
    ${is_date}=    Is Date    ${notification}[notifiedAt]    ${date_format}
    ${is_date_with_millis}=    Is Date    ${notification}[notifiedAt]    ${date_format_with_millis}
    Should Be True    ${is_date} or ${is_date_with_millis}
    [Teardown]    Delete Fixture Data

Check correct attributes are included
    [Documentation]    The structure of the notification message shall be as mandated by clause 5.3.    The Entity Attributes included (Properties or Relationships) shall be those specified by the notification.attributes member in the Subscription data type (clause 5.2.12).
    [Tags]    sub-notification    5_8_6    046_07_02
    Add Initial Entity
    Sleep    1s
    Setup Initial Subscriptions    ${subscription_payload_file_path_watchedAttributes}
    Update Entity Attributes    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}

    ${notification}=    Wait for notification
    Should Be Equal    ${notification}[type]    Notification
    Should Be Equal    ${notification}[subscriptionId]    ${subscription_id}
    ${is_date}=    Is Date    ${notification}[notifiedAt]    ${date_format}
    ${is_date_with_millis}=    Is Date    ${notification}[notifiedAt]    ${date_format_with_millis}
    Should Be True    ${is_date} or ${is_date_with_millis}
    Dictionary Should Contain Key    ${notification}[data][0]    airQualityLevel
    [Teardown]    Delete Fixture Data

Check URI expansion is observed
    [Documentation]    The structure of the notification message shall be as mandated by clause 5.3.    URI expansion shall be observed (clause 5.5.7).
    [Tags]    sub-notification    5_8_6    046_07_03
    Add Initial Entity
    Sleep    1s
    Setup Initial Subscriptions    ${subscription_payload_file_path_default_context}
    Update Entity Attributes    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}

    ${notification}=    Wait for notification
    Should Be Equal    ${notification}[type]    Notification
    Should Be Equal    ${notification}[subscriptionId]    ${subscription_id}
    ${is_date}=    Is Date    ${notification}[notifiedAt]    ${date_format}
    ${is_date_with_millis}=    Is Date    ${notification}[notifiedAt]    ${date_format_with_millis}
    Should Be True    ${is_date} or ${is_date_with_millis}
    Dictionary Should Contain Key    ${notification}[data][0]    https://ngsi-ld-test-suite/context#airQualityLevel
    [Teardown]    Delete Fixture Data


*** Keywords ***
Setup Initial Subscriptions
    [Arguments]    ${subscription_payload_path}=${subscription_payload_file_path}
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=    Load Subscription Sample With Reachable Endpoint
    ...    ${subscription_payload_path}
    ...    ${subscription_id}
    ...    ${notification_server_send_url}
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
    Start Local Server    ${notification_server_host}    ${notification_server_port}

After Test
    Stop Local Server
