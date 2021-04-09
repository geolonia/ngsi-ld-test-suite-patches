*** Settings ***
Documentation   Check if a context source registration subscription defines temporalQ member with timeproperty createdAt or modifiedAt, the temporal query is matched against the managementInterval of matching context source registrations
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource
Resource    ${EXECDIR}/resources/NotificationUtils.resource

Test Template  Receive cSourceNotification For Matching Context Source Registrations On Management Interval
Suite Setup      Start Local Server
Suite Teardown      Delete Created Context Source Registrations

*** Variable ***
${context_source_registration_id_prefix}=  urn:ngsi-ld:ContextSourceRegistration:
${subscription_id_prefix}=  urn:ngsi-ld:Subscription:
${context_source_registration_payload_file_path}=   csourceRegistrations/context-source-registration-managementInterval-sample.jsonld

*** Test Cases ***                        FILEPATH
CreatedAt                                 csourceSubscriptions/subscription-temporalQ-createdAt-sample.jsonld
    [Tags]   csrsub-notification    5_11_7
ModifiedAt                                csourceSubscriptions/subscription-temporalQ-modifiedAt-sample.jsonld
    [Tags]   csrsub-notification    5_11_7

*** Keywords ***
Receive cSourceNotification For Matching Context Source Registrations On Management Interval
    [Arguments]  ${filepath}
    [Documentation]  Check if a context source registration subscription defines temporalQ member with timeproperty createdAt or modifiedAt, the temporal query is matched against the managementInterval of matching context source registrations

    ${subscription_id}=     Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=  Load Subscription Sample With Reachable Endpoint    ${filepath}    ${subscription_id}
    Create Context Source Registration Subscription  ${subscription_payload}
    Set Suite Variable  ${subscription_id}

    ${context_source_registration_id}=     Generate Random Entity Id    ${context_source_registration_id_prefix}
    ${context_source_registration_payload}=  Load Test Sample    ${context_source_registration_payload_file_path}    ${context_source_registration_id}
    Set Suite Variable  ${context_source_registration_id}

    Create Context Source Registration  ${context_source_registration_payload}

    @{expected_context_source_registration_ids}=    Create List     ${context_source_registration_id}

    Wait for notification and validate it   ${subscription_id}  ${expected_context_source_registration_ids}   newlyMatching

    # Moved here since each test case creates a subscription
    [Teardown]  Delete Context Source Registration Subscription     ${subscription_id}

Delete Created Context Source Registrations
    Stop Local Server

    Delete Context Source Registration     ${context_source_registration_id}
