*** Settings ***
Documentation       Check that you can update a subcription: If isActive is equal to true and expiresAt corresponds to a DateTime in the future, then status shall be updated to "active"

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationSubscription.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Setup Initial Subscriptions
Suite Teardown      Delete Initial Subscriptions
Test Template       Activate Paused Subscription With isActive And ExpiresAt Members


*** Variables ***
${subscription_id_prefix}=              urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=      subscriptions/subscription-inactive-sample.jsonld


*** Test Cases ***    SUBSCRIPTION_UPDATE_FRAGMENT_FILE_PATH
029_08_01 ActiveTrueExpiresAt
    [Tags]    sub-update    5_8_2
    subscriptions/fragments/subscription-isActive-expiresAt-update-sample.json


*** Keywords ***
Activate Paused Subscription With isActive And ExpiresAt Members
    [Documentation]    Check that you can update a subcription: If isActive is equal to true and expiresAt corresponds to a DateTime in the future, then status shall be updated to "active"
    [Arguments]    ${subscription_update_fragment_file_path}
    ${response}=    Update Subscription
    ...    ${subscription_id}
    ...    ${subscription_update_fragment_file_path}
    ...    ${CONTENT_TYPE_JSON}
    Check Response Status Code    204    ${response.status_code}
    ${response}=    Retrieve Subscription    ${subscription_id}
    Check Response Body Containing an Attribute set to    status    ${response.json()}    active

Setup Initial Subscriptions
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    Create Subscription    ${subscription_id}    ${subscription_payload_file_path}    ${CONTENT_TYPE_LD_JSON}
    Set Suite Variable    ${subscription_id}

Delete Initial Subscriptions
    Delete Subscription    ${subscription_id}
