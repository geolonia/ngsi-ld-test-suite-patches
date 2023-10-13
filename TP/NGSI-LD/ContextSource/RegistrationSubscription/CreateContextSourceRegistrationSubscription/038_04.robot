*** Settings ***
Documentation       Check that you can create a context source registration subscription with isActive member set to false and it's initial status will be set to "paused"

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Generate Random Ids For Context Source Registration Subscriptions
Suite Teardown      Delete Created Context Source Registration Subscriptions


*** Variables ***
${subscription_id_prefix}=              urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=      csourceSubscriptions/subscription-inactive-sample.jsonld


*** Test Cases ***
038_04_01 Create Inactive Context Source Registration Subscription
    [Documentation]    Check that you can create a context source registration subscription with isActive member set to false and it's initial status will be set to "paused"
    [Tags]    csrsub-create    5_11_2
    ${subscription_payload}=    Load Test Sample    ${subscription_payload_file_path}    ${subscription_id}
    ${response}=    Create Context Source Registration Subscription    ${subscription_payload}
    Check Response Status Code    201    ${response.status_code}
    Check Response Headers Containing URI set to    ${subscription_id}    ${response.headers}
    ${response}=    Retrieve Context Source Registration Subscription
    ...    subscription_id=${subscription_id}
    Check Response Body Containing an Attribute set to    status    ${response.json()}    paused


*** Keywords ***
Generate Random Ids For Context Source Registration Subscriptions
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    Set Suite Variable    ${subscription_id}

Delete Created Context Source Registration Subscriptions
    Delete Context Source Registration Subscription    ${subscription_id}
