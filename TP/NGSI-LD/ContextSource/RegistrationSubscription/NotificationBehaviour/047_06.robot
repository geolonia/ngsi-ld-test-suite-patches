*** Settings ***
Documentation       Check that if a cSourceNotification is not sent successfully, the "notification.timesSent" member shall be incremented by one and the notification.lastFailure" and "notification.lastNotification" members shall be updated with the current timestamp and the status of the context source registration subscription shall be updated to "failed"

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource
Resource            ${EXECDIR}/resources/NotificationUtils.resource

Suite Setup         Setup Initial Context Source Registration Subscriptions
Suite Teardown      Delete Created Context Source Registrations And Subscriptions


*** Variables ***
${context_source_registration_id_prefix}=               urn:ngsi-ld:ContextSourceRegistration:
${subscription_id_prefix}=                              urn:ngsi-ld:Subscription:
${context_source_registration_payload_file_path}=       csourceRegistrations/context-source-registration-sample.jsonld
${subscription_payload_file_path}=                      csourceSubscriptions/subscription-unreachable-endpoint-sample.jsonld
${notification_expectation_file_path}=                  notifications/expectations/1-timesSent-failed.json


*** Test Cases ***
If A cSourceNotification Is Not Successfully Sent The Notification Member Shall Be Updated
    [Documentation]    Check that if a cSourceNotification is not sent successfully, the "notification.timesSent" member shall be incremented by one and the notification.lastFailure" and "notification.lastNotification" members shall be updated with the current timestamp and the status of the context source registration subscription shall be updated to "failed"
    [Tags]    csrsub-notification    5_11_7
    ${context_source_registration_id}=    Generate Random Entity Id    ${context_source_registration_id_prefix}
    ${context_source_registration_payload}=    Load Test Sample
    ...    ${context_source_registration_payload_file_path}
    ...    ${context_source_registration_id}
    Set Suite Variable    ${context_source_registration_id}
    Create Context Source Registration    ${context_source_registration_payload}
    Wait for no notification
    Retrieve Context Source Registration Subscription    ${subscription_id}
    @{expected_notification_additional_members}=    Create List    lastNotification    lastFailure
    Check NotificationParams    ${notification_expectation_file_path}    ${expected_notification_additional_members}


*** Keywords ***
Setup Initial Context Source Registration Subscriptions
    Start Local Server
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=    Load Test Sample    ${subscription_payload_file_path}    ${subscription_id}
    Create Context Source Registration Subscription    ${subscription_payload}
    Set Suite Variable    ${subscription_id}

Delete Created Context Source Registrations And Subscriptions
    Stop Local Server
    Delete Context Source Registration    ${context_source_registration_id}
    Delete Context Source Registration Subscription    ${subscription_id}
