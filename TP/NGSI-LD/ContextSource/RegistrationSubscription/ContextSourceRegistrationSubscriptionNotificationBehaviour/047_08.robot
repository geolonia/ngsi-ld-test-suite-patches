*** Settings ***
Documentation       Check if a context source registration subscription does not define a temporalQ member, a CsourceNotification will be triggered from matching context source registrations for context sources providing latest information

Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistrationSubscription.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistration.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource
Resource            ${EXECDIR}/resources/NotificationUtils.resource

Suite Setup         Setup Initial Context Source Registrations And Subscriptions
Suite Teardown      Delete Created Context Source Registrations And Subscriptions


*** Variables ***
${context_source_registration_id_prefix}=               urn:ngsi-ld:ContextSourceRegistration:
${subscription_id_prefix}=                              urn:ngsi-ld:Subscription:
${context_source_registration_payload_file_path}=       csourceRegistrations/context-source-registration-sample.jsonld
${subscription_payload_file_path}=                      csourceSubscriptions/subscription-sample.jsonld
${update_fragment_file_path}=                           csourceRegistrations/fragments/context-source-registration-update-sample.json


*** Test Cases ***
047_08_01 Receive cSourceNotification For Matching Context Source Registrations Providing Latest Information
    [Documentation]    Check if a context source registration subscription does not define a temporalQ member, a CsourceNotification will be triggered from matching context source registrations for context sources providing latest information
    [Tags]    csrsub-notification    5_11_7
    ${update_fragment}=    Load Test Sample    ${update_fragment_file_path}
    ${response}=    Update Context Source Registration    ${context_source_registration_id}    ${update_fragment}
    @{expected_context_source_registration_ids}=    Create List    ${context_source_registration_id}
    Wait for notification and validate it
    ...    expected_subscription_id=${subscription_id}
    ...    expected_context_source_registration_ids=${expected_context_source_registration_ids}
    ...    expected_trigger_reason=updated


*** Keywords ***
Setup Initial Context Source Registrations And Subscriptions
    Start Local Server
    ${context_source_registration_id}=    Generate Random Entity Id    ${context_source_registration_id_prefix}
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${context_source_registration_payload}=    Load Test Sample
    ...    ${context_source_registration_payload_file_path}
    ...    ${context_source_registration_id}
    ${subscription_payload}=    Load Subscription Sample With Reachable Endpoint
    ...    ${subscription_payload_file_path}
    ...    ${subscription_id}
    Create Context Source Registration    ${context_source_registration_payload}
    Create Context Source Registration Subscription    ${subscription_payload}
    Set Suite Variable    ${context_source_registration_id}
    Set Suite Variable    ${subscription_id}

Delete Created Context Source Registrations And Subscriptions
    Stop Local Server
    Delete Context Source Registration    ${context_source_registration_id}
    Delete Context Source Registration Subscription    ${subscription_id}
