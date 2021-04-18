*** Settings ***
Documentation     Check if a context source registrations subscription does not define a geoproperty in the geoQ member, a CsourceNotification will be triggered from matching context source registrations with a matching location member
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Resource          ${EXECDIR}/resources/NotificationUtils.resource
Suite Setup       Setup Initial Context Source Registration Subscriptions
Suite Teardown    Delete Created Context Source Registrations And Subscriptions

*** Variable ***
${context_source_registration_id_prefix}=    urn:ngsi-ld:ContextSourceRegistration:
${subscription_id_prefix}=    urn:ngsi-ld:Subscription:
${context_source_registration_payload_file_path}=    csourceRegistrations/context-source-registration-location-sample.jsonld
${subscription_payload_file_path}=    csourceSubscriptions/subscription-geoQ-without-geoproperty-sample.jsonld

*** Test Case ***
Receive cSourceNotification For Matching Context Source Registrations On Location As Default
    [Documentation]    Check if a context source registrations subscription does not define a geoproperty in the geoQ member, a CsourceNotification will be triggered from matching context source registrations with a matching location member
    [Tags]    csrsub-notification    5_11_7
    ${context_source_registration_id}=    Generate Random Entity Id    ${context_source_registration_id_prefix}
    ${context_source_registration_payload}=    Load Test Sample    ${context_source_registration_payload_file_path}    ${context_source_registration_id}
    Set Suite Variable    ${context_source_registration_id}
    Create Context Source Registration    ${context_source_registration_payload}
    @{expected_context_source_registration_ids}=    Create List    ${context_source_registration_id}
    Wait for notification and validate it    ${subscription_id}    ${expected_context_source_registration_ids}    newlyMatching

*** Keywords ***
Setup Initial Context Source Registration Subscriptions
    Start Local Server
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=    Load Subscription Sample With Reachable Endpoint    ${subscription_payload_file_path}    ${subscription_id}
    Create Context Source Registration Subscription    ${subscription_payload}
    Set Suite Variable    ${subscription_id}

Delete Created Context Source Registrations And Subscriptions
    Stop Local Server
    Delete Context Source Registration    ${context_source_registration_id}
    Delete Context Source Registration Subscription    ${subscription_id}
