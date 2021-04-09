*** Settings ***
Documentation   Check that instead of providing the original context source registration, implementations should return context source registration information relevant for the subscription, in particular only matching RegistrationInfo elements
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource
Resource    ${EXECDIR}/resources/NotificationUtils.resource

Suite Setup      Setup Initial Context Source Registration Subscriptions
Suite Teardown      Delete Created Context Source Registrations And Subscriptions

*** Variable ***
${context_source_registration_id_prefix}=  urn:ngsi-ld:ContextSourceRegistration:
${subscription_id_prefix}=  urn:ngsi-ld:Subscription:
${context_source_registration_payload_file_path}=   csourceRegistrations/context-source-registration-building-and-bus-entities-sample.jsonld
${subscription_payload_file_path}=   csourceSubscriptions/subscription-sample.jsonld

*** Test Case ***
Receive cSourceNotification With Relevant Information
    [Documentation]  Check that instead of providing the original context source registration, implementations should return context source registration information relevant for the subscription, in particular only matching RegistrationInfo elements
    [Tags]   csrsub-notification    5_11_7

    ${context_source_registration_id}=     Generate Random Entity Id    ${context_source_registration_id_prefix}
    ${context_source_registration_payload}=  Load Test Sample    ${context_source_registration_payload_file_path}    ${context_source_registration_id}
    Set Suite Variable  ${context_source_registration_id}

    Create Context Source Registration  ${context_source_registration_payload}

    @{expected_context_source_registration_ids}=    Create List     ${context_source_registration_id}
    @{expected_notification_data_entities}=    Create List     Building

    Wait for notification and validate it   ${subscription_id}  ${expected_context_source_registration_ids}   newlyMatching   ${expected_notification_data_entities}

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
