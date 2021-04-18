*** Settings ***
Documentation     Check that you can create a context source registration subscription with an expiresAt member and when it is due the status of the subscription changes to expired
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Suite Setup       Generate Random Ids For Context Source Registration Subscriptions
Suite Teardown    Delete Created Context Source Registration Subscriptions

*** Variable ***
${subscription_id_prefix}=    urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=    csourceSubscriptions/subscription-expiresAt-sample.jsonld

*** Test Case ***
Create Context Source Registration Subscription With expiresAt Member
    [Documentation]    Check that you can create a context source registration subscription with an expiresAt member and when it is due the status of the subscription changes to expired
    [Tags]    csrsub-create    5_11_2
    ${subscription_payload_sample}=    Load Test Sample    ${subscription_payload_file_path}    ${subscription_id}
    ${current_date}=    Get Current Date    time_zone=UTC    result_format=${date_format}
    ${expiresAt}=    Add Time To Date    ${current_date}    10 seconds    date_format=${date_format}
    ${subscription_payload}=    Update Value To Json    ${subscription_payload_sample}    $..expiresAt    ${expiresAt}
    Create Context Source Registration Subscription    ${subscription_payload}
    Check Response Status Code Set To    201
    Check Response Headers Containing URI set to    ${request['path']}/    ${subscription_id}    ${response}
    Sleep    15s
    Retrieve context source registration subscription    ${subscription_id}
    Check Response Body Containing an Attribute set to    status    expired

*** Keywords ***
Generate Random Ids For Context Source Registration Subscriptions
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    Set Suite Variable    ${subscription_id}

Delete Created Context Source Registration Subscriptions
    Delete Context Source Registration Subscription    ${subscription_id}
