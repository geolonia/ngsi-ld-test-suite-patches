*** Settings ***
Documentation       Check if a context source registration subscription defines an "entities" member, a CsourceNotification will be triggered from context source registrations with information member matching the described "entities"

Resource            ${EXECDIR}/resources/ApiUtils.resource
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
${update_fragment_file_path}=                           csourceRegistrations/fragments/context-source-registration-update-information-sample.json


*** Test Cases ***
Receive cSourceNotification For No Longer Matching Context Source Registrations Providing Latest Information
    [Documentation]    Check if a context source registration subscription defines an "entities" member, a CsourceNotification will be triggered from context source registrations with information member matching the described "entities"
    [Tags]    csrsub-notification    5_11_7
    ${update_fragment}=    Load Test Sample    ${update_fragment_file_path}
    Update Context Source Registration    ${context_source_registration_id}    ${update_fragment}
    @{expected_context_source_registration_ids}=    Create List    ${context_source_registration_id}
    Wait for notification and validate it
    ...    ${subscription_id}
    ...    ${expected_context_source_registration_ids}
    ...    noLongerMatching


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
