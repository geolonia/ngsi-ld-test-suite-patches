*** Settings ***
Documentation       Check that one can create a subscription with a datasetId

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationSubscription.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Teardown      Delete Initial Subscription


*** Variables ***
${subscription_payload_file_path}           subscriptions/subscription-building-with-datasetId.jsonld
${subscription_expectation_file_path}       subscriptions/expectations/subscription-with-datasetId.jsonld


*** Test Cases ***
028_06 Create A Subscription With A datasetId
    [Documentation]    Check that one can create a subscription with a datasetId
    [Tags]    sub-create    5_8_1    4_5_5    since_v1.8.1
    ${subscription_id}=    Generate Random Subscription Id
    Set Suite Variable    ${subscription_id}
    ${response}=    Create Subscription
    ...    ${subscription_id}
    ...    ${subscription_payload_file_path}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${expected_subscription}=    Load Test Sample    ${subscription_expectation_file_path}    ${subscription_id}
    ${response1}=    Retrieve Subscription
    ...    id=${subscription_id}
    ...    accept=${CONTENT_TYPE_LD_JSON}
    ...    context=${ngsild_test_suite_context}
    Check Created Resource Set To    ${expected_subscription}    ${response1.json()}


*** Keywords ***
Delete Initial Subscription
    Delete Subscription    ${subscription_id}
