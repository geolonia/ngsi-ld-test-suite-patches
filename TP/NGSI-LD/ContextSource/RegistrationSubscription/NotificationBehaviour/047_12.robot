*** Settings ***
Documentation       Check if a context source registrations subscription defines entities member and watchedAttributes member, a CsourceNotification will be triggered from context source registrations with information member matching the described "entities" and "attributes"

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource
Resource            ${EXECDIR}/resources/NotificationUtils.resource

Suite Setup         Setup Initial Context Source Registration Subscriptions
Suite Teardown      Delete Created Context Source Registrations And Subscriptions


*** Variables ***
${context_source_registration_id_prefix}=               urn:ngsi-ld:ContextSourceRegistration:
${subscription_id_prefix}=                              urn:ngsi-ld:Subscription:
${context_source_registration_payload_file_path}=       csourceRegistrations/context-source-registration-detailed-information-sample.jsonld
${subscription_payload_file_path}=                      csourceSubscriptions/subscription-watchedAttributes-sample.jsonld


*** Test Cases ***
047_12_01 Receive cSourceNotification For Matching Context Source Registrations On Watched Attributes
    [Documentation]    Check if a context source registrations subscription defines entities member and watchedAttributes member, a CsourceNotification will be triggered from context source registrations with information member matching the described "entities" and "attributes"
    [Tags]    csrsub-notification    5_11_7
    ${context_source_registration_id}=    Generate Random Entity Id    ${context_source_registration_id_prefix}
    ${context_source_registration_payload}=    Load Test Sample
    ...    ${context_source_registration_payload_file_path}
    ...    ${context_source_registration_id}
    Set Suite Variable    ${context_source_registration_id}
    ${response}=    Create Context Source Registration    ${context_source_registration_payload}
    @{expected_context_source_registration_ids}=    Create List    ${context_source_registration_id}
    Wait for notification and validate it
    ...    ${subscription_id}
    ...    ${expected_context_source_registration_ids}
    ...    newlyMatching


*** Keywords ***
Setup Initial Context Source Registration Subscriptions
    Start Local Server
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=    Load Subscription Sample With Reachable Endpoint
    ...    ${subscription_payload_file_path}
    ...    ${subscription_id}
    Create Context Source Registration Subscription    ${subscription_payload}
    Set Suite Variable    ${subscription_id}

Delete Created Context Source Registrations And Subscriptions
    Stop Local Server
    Delete Context Source Registration    ${context_source_registration_id}
    Delete Context Source Registration Subscription    ${subscription_id}
