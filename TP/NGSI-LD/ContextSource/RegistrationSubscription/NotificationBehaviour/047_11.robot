*** Settings ***
Documentation       Check if a context source registration subscription defines temporalQ member with timeproperty createdAt or modifiedAt, the temporal query is matched against the managementInterval of matching context source registrations

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource
Resource            ${EXECDIR}/resources/NotificationUtils.resource

Suite Setup         Start Local Server
Suite Teardown      Stop Local Server
Test Teardown       Delete Created Context Source Registrations
Test Template       Receive cSourceNotification For Matching Context Source Registrations On Management Interval


*** Variables ***
${context_source_registration_id_prefix}=               urn:ngsi-ld:ContextSourceRegistration:
${subscription_id_prefix}=                              urn:ngsi-ld:Subscription:
${context_source_registration_payload_file_path}=       csourceRegistrations/context-source-registration-managementInterval-sample.jsonld


*** Test Cases ***    FILEPATH
047_11_01 CreatedAt    [Tags]    csrsub-notification    5_11_7
    csourceSubscriptions/subscription-temporalQ-createdAt-sample.jsonld
047_11_02 ModifiedAt    [Tags]    csrsub-notification    5_11_7
    csourceSubscriptions/subscription-temporalQ-modifiedAt-sample.jsonld


*** Keywords ***
Receive cSourceNotification For Matching Context Source Registrations On Management Interval
    [Documentation]    Check if a context source registration subscription defines temporalQ member with timeproperty createdAt or modifiedAt, the temporal query is matched against the managementInterval of matching context source registrations
    [Arguments]    ${filepath}
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    Set Suite Variable    ${subscription_id}
    ${subscription_payload}=    Load Subscription Sample With Reachable Endpoint    ${filepath}    ${subscription_id}
    ${response}=    Create Context Source Registration Subscription    ${subscription_payload}
    ${context_source_registration_id}=    Generate Random Entity Id    ${context_source_registration_id_prefix}
    Set Suite Variable    ${context_source_registration_id}
    ${context_source_registration_payload}=    Load Test Sample
    ...    ${context_source_registration_payload_file_path}
    ...    ${context_source_registration_id}
    ${response}=    Create Context Source Registration    ${context_source_registration_payload}
    @{expected_context_source_registration_ids}=    Create List    ${context_source_registration_id}
    Wait for notification and validate it
    ...    expected_subscription_id=${subscription_id}
    ...    expected_context_source_registration_ids=${expected_context_source_registration_ids}
    ...    expected_trigger_reason=newlyMatching

Delete Created Context Source Registrations
    Delete Context Source Registration Subscription    ${subscription_id}
    Delete Context Source Registration    ${context_source_registration_id}
