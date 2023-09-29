*** Settings ***
Documentation       If the response to the notification request is different than 200 OK then implementations shall: Update notification.lastFailure with a timestamp representing the current date and time, update notification.status to "failed"

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationSubscription.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource
Resource            ${EXECDIR}/resources/NotificationUtils.resource
Resource            ${EXECDIR}/resources/MockServerUtils.resource

Suite Setup         Before Test
Suite Teardown      After Test


*** Variables ***
${subscription_id_prefix}=              urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=      subscriptions/subscription-building-entities-active.jsonld
${building_id_prefix}=                  urn:ngsi-ld:Building:
${entity_building_filepath}=            building-simple-attributes-sample.jsonld
${fragment_filename}=                   airQualityLevel-fragment.jsonld


*** Test Cases ***
046_13_01 Check that lastFailure and status are updated if a notification could not be sent
    [Documentation]    If the response to the notification request is different than 200 OK then implementations shall: Update notification.lastFailure with a timestamp representing the current date and time, update notification.status to "failed"
    [Tags]    sub-notification    5_8_6    046_13

    @{expected_notification_data_entities}=    Create List    Building
    Update Entity Attributes    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}

    Sleep    10s

    ${response}=    Retrieve Subscription
    ...    ${subscription_id}
    ...    accept=${CONTENT_TYPE_LD_JSON}
    ...    context=${ngsild_test_suite_context}

    ${notification_info}=    Get Value From Json    ${response.json()}    $.notification

    Dictionary Should Contain Key    ${notification_info}[0]    status
    Should Be Equal    failed    ${notification_info}[0][status]

    Dictionary Should Contain Key    ${notification_info}[0]    lastFailure
    ${last_failure_date}=    Parse Ngsild Date    ${notification_info}[0][lastFailure]
    Should Not Be Equal    ${last_failure_date}    ${None}


*** Keywords ***
Setup Initial Subscription
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    Create Subscription    ${subscription_id}    ${subscription_payload_file_path}    ${CONTENT_TYPE_LD_JSON}
    Set Suite Variable    ${subscription_id}

Delete Initial Subscription
    Delete Subscription    ${subscription_id}

Add Initial Entity
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Create Entity    ${entity_building_filepath}    ${entity_id}
    Set Suite Variable    ${entity_id}

Delete Initial Entity
    Delete Entity by Id    ${entity_id}

Before Test
    Setup Initial Subscription
    Add Initial Entity

After Test
    Delete Initial Subscription
    Delete Initial Entity
