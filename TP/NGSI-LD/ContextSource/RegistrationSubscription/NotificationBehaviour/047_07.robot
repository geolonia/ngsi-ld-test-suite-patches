*** Settings ***
Documentation       Check that a cSourceNotification shall only be sent if and only if the status of the corresponding subscription is active, neither paused or expired

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource
Resource            ${EXECDIR}/resources/NotificationUtils.resource

Suite Setup         Setup Initial Context Source Registration Subscriptions
Suite Teardown      Delete Created Context Source Registrations And Subscriptions
Test Template       Do Not Receive cSourceNotification If Subscription Status Is Not Active


*** Variables ***
${context_source_registration_id_prefix}=               urn:ngsi-ld:ContextSourceRegistration:
${subscription_id_prefix}=                              urn:ngsi-ld:Subscription:
${context_source_registration_payload_file_path}=       csourceRegistrations/context-source-registration-sample.jsonld
${subscription_payload_file_path}=                      csourceSubscriptions/subscription-sample.jsonld


*** Test Cases ***    FILEPATH
047_07_01 PausedSubscription
    [Tags]    csrsub-notification    5_11_7
    csourceSubscriptions/fragments/subscription-isActive-update-sample.json
047_07_02 ExpiredSubscription
    [Tags]    csrsub-notification    5_11_7
    csourceSubscriptions/fragments/subscription-expiresAt-update-sample.json


*** Keywords ***
Do Not Receive cSourceNotification If Subscription Status Is Not Active
    [Documentation]    Check that a cSourceNotification shall only be sent if and only if the status of the corresponding subscription is active, neither paused or expired
    [Arguments]    ${filepath}
    Set Global Variable    ${filepath}
    ${context_source_registration_id}=    Generate Random Entity Id    ${context_source_registration_id_prefix}
    ${context_source_registration_payload}=    Load Test Sample
    ...    ${context_source_registration_payload_file_path}
    ...    ${context_source_registration_id}
    Set Suite Variable    ${context_source_registration_id}
    ${response}=    Create Context Source Registration    ${context_source_registration_payload}
    Wait for no notification

Setup Initial Context Source Registration Subscriptions
    Start Local Server
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=    Load Subscription Sample With Reachable Endpoint
    ...    ${subscription_payload_file_path}
    ...    ${subscription_id}
    Create Context Source Registration Subscription    ${subscription_payload}
    Set Suite Variable    ${subscription_id}
    ${subscription_update_fragment}=    Load Test Sample    ${filepath}
    ${response}=    Update Context Source Registration Subscription
    ...    ${subscription_id}
    ...    ${subscription_update_fragment}

Delete Created Context Source Registrations And Subscriptions
    Stop Local Server
    Delete Context Source Registration    ${context_source_registration_id}
    Delete Context Source Registration Subscription    ${subscription_id}
