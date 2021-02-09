*** Settings ***
Documentation   Check that a cSourceNotification shall only be sent if and only if the status of the corresponding subscription is active not paused nor expired
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource
Resource    ${EXECDIR}/resources/NotificationUtils.resource

Test Template  Do Not Receive cSourceNotification If Subscription Status Is Not Active
Suite Setup      Setup Initial Context Source Registration Subscriptions
Suite Teardown      Delete Created Context Source Registrations And Subscriptions

*** Variable ***
${context_source_registration_id_prefix}=  urn:ngsi-ld:ContextSourceRegistration:
${subscription_id_prefix}=  urn:ngsi-ld:Subscription:
${context_source_registration_payload_file_path}=   csourceRegistrations/context-source-registration-sample.jsonld
${subscription_payload_file_path}=   csourceSubscriptions/subscription-sample.jsonld

*** Test Cases ***                        FILEPATH
PausedSubscription                        csourceSubscriptions/fragments/subscription-isActive-update-sample.json
ExpiredSubscription                       csourceSubscriptions/fragments/subscription-expiresAt-update-sample.json

*** Keywords ***
Do Not Receive cSourceNotification If Subscription Status Is Not Active
    [Arguments]  ${filepath}
    [Documentation]  Check that a cSourceNotification shall only be sent if and only if the status of the corresponding subscription is active not paused nor expired
    [Tags]  mandatory

    ${subscription_update_fragment}=    Load Test Sample    ${filepath}
    Update Context Source Registration Subscription     ${subscription_id}      ${subscription_update_fragment}

    ${context_source_registration_id}=     Generate Random Entity Id    ${context_source_registration_id_prefix}
    ${context_source_registration_payload}=  Load Test Sample    ${context_source_registration_payload_file_path}    ${context_source_registration_id}
    Set Suite Variable  ${context_source_registration_id}

    Create Context Source Registration  ${context_source_registration_payload}

    Wait for no notification

*** Keywords ***
Setup Initial Context Source Registration Subscriptions
    Start Local Server

    ${subscription_id}=     Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=  Load Subscription Sample With Reachable Endpoint    ${subscription_payload_file_path}    ${subscription_id}
    Create Context Source Registration Subscription  ${subscription_payload}

    Set Suite Variable  ${subscription_id}

Delete Created Context Source Registrations And Subscriptions
    Stop Local Server

    Delete Context Source Registration     ${context_source_registration_id}
    Delete Context Source Registration Subscription     ${subscription_id}
