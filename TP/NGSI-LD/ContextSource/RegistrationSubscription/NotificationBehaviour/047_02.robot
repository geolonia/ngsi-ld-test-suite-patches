*** Settings ***
Documentation       Check that if the created context source registration subscription does not define a timeInterval member, a cSourceNotification, with the appropriate trigger reason in the "triggerReason" member, will be sent initially on subscription and whenever there is a change of a matching Context Source Registration

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource
Resource            ${EXECDIR}/resources/NotificationUtils.resource

Suite Setup         Setup Initial Context Source Registrations
Suite Teardown      Delete Created Context Source Registrations And Subscriptions


*** Variables ***
${context_source_registration_id_prefix}=               urn:ngsi-ld:ContextSourceRegistration:
${subscription_id_prefix}=                              urn:ngsi-ld:Subscription:
${context_source_registration_payload_file_path}=       csourceRegistrations/context-source-registration-sample.jsonld
${subscription_payload_file_path}=                      csourceSubscriptions/subscription-sample.jsonld
${update_fragment_file_path}=                           csourceRegistrations/fragments/context-source-registration-update-sample.json


*** Test Cases ***
047_02_01 Receive cSourceNotification Initially On Subscription And Whenever There Is A Change Of A Matching Context Source Registration
    [Documentation]    Check that if the created context source registration subscription does not define a timeInterval member, a cSourceNotification, with the appropriate trigger reason in the "triggerReason" member, will be sent initially on subscription and whenever there is a change of a matching Context Source Registration
    [Tags]    csrsub-notification    5_11_7
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=    Load Subscription Sample With Reachable Endpoint
    ...    ${subscription_payload_file_path}
    ...    ${subscription_id}
    Set Suite Variable    ${subscription_id}
    ${response}=    Create Context Source Registration Subscription    ${subscription_payload}
    @{expected_context_source_registration_ids}=    Create List    ${context_source_registration_id}
    Wait for notification and validate it
    ...    ${subscription_id}
    ...    ${expected_context_source_registration_ids}
    ...    newlyMatching
    ${update_fragment}=    Load Test Sample    ${update_fragment_file_path}
    ${response}=    Update Context Source Registration    ${context_source_registration_id}    ${update_fragment}
    Wait for notification and validate it
    ...    ${subscription_id}
    ...    ${expected_context_source_registration_ids}
    ...    updated


*** Keywords ***
Setup Initial Context Source Registrations
    Start Local Server
    ${context_source_registration_id}=    Generate Random Entity Id    ${context_source_registration_id_prefix}
    ${context_source_registration_payload}=    Load Test Sample
    ...    ${context_source_registration_payload_file_path}
    ...    ${context_source_registration_id}
    Create Context Source Registration    ${context_source_registration_payload}
    Set Suite Variable    ${context_source_registration_id}

Delete Created Context Source Registrations And Subscriptions
    Stop Local Server
    Delete Context Source Registration    ${context_source_registration_id}
    Delete Context Source Registration Subscription    ${subscription_id}
