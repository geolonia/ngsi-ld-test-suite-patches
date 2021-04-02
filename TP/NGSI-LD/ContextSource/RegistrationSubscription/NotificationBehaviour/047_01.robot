*** Settings ***
Documentation   Check that if the created context source registration subscription defines a timeInterval member, a cSourceNotification will be sent periodically, initially on subscription and when the time interval is reached
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource
Resource    ${EXECDIR}/resources/NotificationUtils.resource

Suite Setup      Setup Initial Context Source Registrations
Suite Teardown      Delete Created Context Source Registrations And Subscriptions

*** Variable ***
${context_source_registration_id_prefix}=  urn:ngsi-ld:ContextSourceRegistration:
${subscription_id_prefix}=  urn:ngsi-ld:Subscription:
${context_source_registration_payload_file_path}=   csourceRegistrations/context-source-registration-sample.jsonld
${subscription_payload_file_path}=   csourceSubscriptions/subscription-timeInterval-sample.jsonld

*** Test Case ***
Receive cSourceNotification Periodically And Initially On Subscription
    [Documentation]  Check that if the created context source registration subscription defines a timeInterval member, a cSourceNotification will be sent periodically, initially on subscription and when the time interval is reached
    [Tags]   csrsub-notification    5_11_7

    ${subscription_id}=     Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=  Load Subscription Sample With Reachable Endpoint    ${subscription_payload_file_path}    ${subscription_id}
    Set Suite Variable  ${subscription_id}

    Create Context Source Registration Subscription  ${subscription_payload}

    Wait for notification
    # Wait for 15 seconds to check if another notification was sent
    Wait for notification   timeout=${15}

*** Keywords ***
Setup Initial Context Source Registrations
    Start Local Server

    ${context_source_registration_id}=     Generate Random Entity Id    ${context_source_registration_id_prefix}
    ${context_source_registration_payload}=  Load Test Sample    ${context_source_registration_payload_file_path}    ${context_source_registration_id}
    Create Context Source Registration  ${context_source_registration_payload}

    Set Suite Variable  ${context_source_registration_id}

Delete Created Context Source Registrations And Subscriptions
    Stop Local Server

    Delete Context Source Registration     ${context_source_registration_id}
    Delete Context Source Registration Subscription     ${subscription_id}
