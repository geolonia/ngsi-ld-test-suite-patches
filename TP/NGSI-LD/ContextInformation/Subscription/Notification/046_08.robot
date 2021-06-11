*** Settings ***
Documentation     Check that a notification is only sent if and only if the status is active
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Resource          ${EXECDIR}/resources/NotificationUtils.resource
Suite Setup       Setup Initial Subscriptions
Suite Teardown    Delete Initial Subscriptions

*** Variable ***
${subscription_id_prefix}=    urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=    subscriptions/subscription-building-entities-active.jsonld
${building_id_prefix}=    urn:ngsi-ld:Building:




*** Keywords ***
Check that a notification is only sent if statis is active
    [Arguments]      ${fragment_filename}    
    [Documentation]     Check that a notification is only sent if and only if the status is active
    [Tags]    sub-notification    5_11_7
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=    Load Subscription Sample With Reachable Endpoint    ${subscription_payload_file_path}    ${subscription_id}
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}

    @{expected_notification_data_entities}=    Create List    Building
    Wait for notification and validate it    ${subscription_id}    ${expected_context_source_registration_ids}    newlyMatching    ${expected_notification_data_entities}

    Set Suite Variable    ${subscription_id}
    Update Entity Attributes    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}
    Wait for subscription notification and validate it  ${subscription_id}  ${expected_notification_data_entities}  timeout=${5}





