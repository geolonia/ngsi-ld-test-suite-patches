*** Settings ***
Documentation     The notification.lastNotification member shall be updated with a timestamp representing the current date and time. This test will check the format.

Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Resource          ${EXECDIR}/resources/NotificationUtils.resource
Resource          ${EXECDIR}/resources/MockServerUtils.resource

Suite Setup       Setup Initial Subscription
Suite Teardown    Delete Initial Subscription

*** Variable ***
${subscription_id_prefix}=    urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=    subscriptions/subscription-building-entities-active.jsonld
${building_id_prefix}=    urn:ngsi-ld:Building:
${fragment_filename}=    airQualityLevel-fragment.jsonld

*** Test Case ***
Check that a notification is only sent if statis is active
    [Documentation]     The notification.lastNotification member shall be updated with a timestamp representing the current date and time. This test will check the format.
    [Tags]    sub-notification    5_11_7    046_13
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}

    @{expected_notification_data_entities}=    Create List    Building
    Update Entity Attributes    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}

    Wait for redirected request

    @{expected_notification_additional_members}=    Create List    lastNotification    lastSuccess
    Check NotificationParams    ${notification_expectation_file_path}    ${expected_notification_additional_members}
    

*** Keywords ***
Setup Initial Subscription
    Start Local Server
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    Create Subscription     ${subscription_id}     ${subscription_payload_file_path}    ${CONTENT_TYPE_LD_JSON} 
    Set Suite Variable    ${subscription_id}

Delete Initial Subscription
    Stop Local Server
    Delete Subscription      ${subscription_id}


