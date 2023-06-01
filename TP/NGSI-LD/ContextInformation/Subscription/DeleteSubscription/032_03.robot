*** Settings ***
Documentation       Check that you can delete a subscription

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Setup Initial Subscriptions
Suite Teardown      Delete Initial Subscriptions


*** Variables ***
${subscription_id_prefix}=              urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=      subscriptions/subscription-sample.jsonld


*** Test Cases ***
Delete Subscription
    [Documentation]    Check that you can delete a subscription
    [Tags]    sub-delete    5_8_5
    ${response}=    Delete Subscription    ${subscription_id}
    Check Response Status Code    204    ${response.status_code}
    ${response}=    Retrieve Subscription    ${subscription_id}
    Check SUT Not Containing Resource


*** Keywords ***
Setup Initial Subscriptions
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    Create Subscription    ${subscription_id}    ${subscription_payload_file_path}    ${CONTENT_TYPE_LD_JSON}
    Set Suite Variable    ${subscription_id}

Delete Initial Subscriptions
    Delete Subscription    ${subscription_id}
