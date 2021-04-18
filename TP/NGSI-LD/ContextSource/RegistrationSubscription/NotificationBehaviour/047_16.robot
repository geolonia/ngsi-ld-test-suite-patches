*** Settings ***
Documentation     Check if you update a context source registration subscription, a CsourceNotification will be sent with all currently matching context source registrations
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Resource          ${EXECDIR}/resources/NotificationUtils.resource
Test Template     Receive cSourceNotification For Newly Matching Context Source Registrations
Suite Setup       Setup Initial Context Source Registrations And Subscriptions
Suite Teardown    Delete Created Context Source Registrations And Subscriptions

*** Variable ***
${context_source_registration_id_prefix}=    urn:ngsi-ld:ContextSourceRegistration:
${subscription_id_prefix}=    urn:ngsi-ld:Subscription:
${first_context_source_registration_payload_file_path}=    csourceRegistrations/context-source-registration-vehicle-entities-sample.jsonld
${second_context_source_registration_payload_file_path}=    csourceRegistrations/context-source-registration-bus-entities-sample.jsonld
${subscription_payload_file_path}=    csourceSubscriptions/subscription-sample.jsonld

*** Test Cases ***    FILEPATH                                                                            NOTIFICATION_CSR_IDS
MatchFirstContextSourceRegistration
                      csourceSubscriptions/fragments/subscription-vehicle-entities-sample.json            ${first_context_source_registration_id}
                      [Tags]                                                                              csrsub-notification                         5_11_7

MatchSecondContextSourceRegistration
                      csourceSubscriptions/fragments/subscription-bus-entities-sample.json                ${second_context_source_registration_id}
                      [Tags]                                                                              csrsub-notification                         5_11_7

MatchBothContextSourceRegistrations
                      csourceSubscriptions/fragments/subscription-vehicle-and-bus-entities-sample.json    ${first_context_source_registration_id}     ${second_context_source_registration_id}
                      [Tags]                                                                              csrsub-notification                         5_11_7

*** Keywords ***
Receive cSourceNotification For Newly Matching Context Source Registrations
    [Arguments]    ${filepath}    @{notification_csr_ids}
    [Documentation]    Check if you update a context source registration subscription, a CsourceNotification will be sent with all currently matching context source registrations
    ${subscription_update_fragment}=    Load Test Sample    ${filepath}
    Update Context Source Registration Subscription    ${subscription_id}    ${subscription_update_fragment}
    Wait for notification and validate it    ${subscription_id}    ${notification_csr_ids}    newlyMatching

Setup Initial Context Source Registrations And Subscriptions
    Start Local Server
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${first_context_source_registration_id}=    Generate Random Entity Id    ${context_source_registration_id_prefix}
    ${second_context_source_registration_id}=    Generate Random Entity Id    ${context_source_registration_id_prefix}
    ${subscription_payload}=    Load Subscription Sample With Reachable Endpoint    ${subscription_payload_file_path}    ${subscription_id}
    ${first_context_source_registration_payload}=    Load Test Sample    ${first_context_source_registration_payload_file_path}    ${first_context_source_registration_id}
    ${second_context_source_registration_payload}=    Load Test Sample    ${second_context_source_registration_payload_file_path}    ${second_context_source_registration_id}
    Create Context Source Registration Subscription    ${subscription_payload}
    Create Context Source Registration    ${first_context_source_registration_payload}
    Create Context Source Registration    ${second_context_source_registration_payload}
    Set Suite Variable    ${subscription_id}
    Set Suite Variable    ${first_context_source_registration_id}
    Set Suite Variable    ${second_context_source_registration_id}

Delete Created Context Source Registrations And Subscriptions
    Stop Local Server
    Delete Context Source Registration Subscription    ${subscription_id}
    Delete Context Source Registration    ${first_context_source_registration_id}
    Delete Context Source Registration    ${second_context_source_registration_id}
