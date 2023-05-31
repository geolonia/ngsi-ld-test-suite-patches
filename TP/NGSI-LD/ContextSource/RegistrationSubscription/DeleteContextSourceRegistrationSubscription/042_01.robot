*** Settings ***
Documentation       Check that you can delete a context source registration subscription

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Setup Initial Context Source Registration Subscriptions


*** Variables ***
${subscription_id_prefix}=              urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=      csourceSubscriptions/subscription-sample.jsonld


*** Test Cases ***
Delete Context Source Registration Subscription
    [Documentation]    Check that you can delete a context source registration subscription
    [Tags]    csrsub-delete    5_11_6
    Delete Context Source Registration Subscription    ${subscription_id}
    Check Response Status Code Set To    204
    Retrieve Context Source Registration Subscription    ${subscription_id}    context=${ngsild_test_suite_context}
    Check SUT Not Containing Resource


*** Keywords ***
Setup Initial Context Source Registration Subscriptions
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=    Load Test Sample    ${subscription_payload_file_path}    ${subscription_id}
    Create Context Source Registration Subscription    ${subscription_payload}
    Set Suite Variable    ${subscription_id}
