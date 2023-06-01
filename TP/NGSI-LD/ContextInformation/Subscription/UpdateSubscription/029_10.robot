*** Settings ***
Documentation       Check that you can update a subscription: If only expiresAt is included and refers to a DateTime in the future, then status shall be updated to "active", if and only if the previous value of status was "expired"

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Setup Initial Subscriptions
Suite Teardown      Delete Initial Subscriptions


*** Variables ***
${subscription_id_prefix}                       urn:ngsi-ld:Subscription:
${subscription_payload_file_path}               subscriptions/subscription-sample.jsonld
${subscription_update_fragment_file_path}       subscriptions/fragments/subscription-expiresAt-future-update-sample.json


*** Test Cases ***
Activate Expired Subscription
    [Documentation]    Check that you can update a subscription: If only expiresAt is included and refers to a DateTime in the future, then status shall be updated to "active", if and only if the previous value of status was "expired"
    [Tags]    sub-update    5_8_2
    # Update subscription to expire in 5 seconds
    ${now}=    Get Current Date    time_zone=UTC
    ${in_5_seconds}=    Add Time To Date    ${now}    5s    result_format=%Y-%m-%dT%H:%M:%SZ
    ${update_template_fragment}=    Load JSON From File
    ...    ${EXECDIR}/data/subscriptions/fragments/subscription-expiresAt-update-sample.json
    ${update_fragment}=    Update Value To JSON    ${update_template_fragment}    $..expiresAt    ${in_5_seconds}
    ${response}=    Update Subscription With Payload
    ...    ${subscription_id}
    ...    ${update_fragment}
    ...    ${CONTENT_TYPE_JSON}
    Sleep    10s
    ${response}=    Update Subscription
    ...    ${subscription_id}
    ...    ${subscription_update_fragment_file_path}
    ...    ${CONTENT_TYPE_JSON}
    Check Response Status Code    204    ${response.status_code}
    ${response}=    Retrieve Subscription    ${subscription_id}
    Check Response Body Containing an Attribute set to    status    ${response.json()}    active


*** Keywords ***
Setup Initial Subscriptions
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    Create Subscription    ${subscription_id}    ${subscription_payload_file_path}    ${CONTENT_TYPE_LD_JSON}
    Set Suite Variable    ${subscription_id}

Delete Initial Subscriptions
    Delete Subscription    ${subscription_id}
