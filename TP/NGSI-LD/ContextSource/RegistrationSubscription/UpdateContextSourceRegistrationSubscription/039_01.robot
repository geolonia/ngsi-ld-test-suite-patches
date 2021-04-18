*** Settings ***
Documentation     Check that you can update a context source registration subscription
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Suite Setup       Setup Initial Context Source Registration Subscriptions
Suite Teardown    Delete Initial Context Source Registration Subscriptions

*** Variable ***
${subscription_id_prefix}=    urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=    csourceSubscriptions/subscription-sample.jsonld
${subscription_update_fragment_file_path}=    csourceSubscriptions/fragments/subscription-update-sample.json

*** Test Case ***
Update Context Source Registration Subscription
    [Documentation]    Check that you can update a context source registration subscription
    [Tags]    csrsub-update    5_11_3
    ${subscription_update_fragment}=    Load Test Sample    ${subscription_update_fragment_file_path}
    Update Context Source Registration Subscription    ${subscription_id}    ${subscription_update_fragment}
    Check Response Status Code Set To    204
    ${subscription}=    Upsert Element In Entity    ${subscription_payload}    ${subscription_update_fragment}
    Retrieve Context Source Registration Subscription    ${subscription_id}    context=${ngsild_test_suite_context}    accept=${CONTENT_TYPE_LD_JSON}
    Check Updated Resource Set To    ${subscription}

*** Keywords ***
Setup Initial Context Source Registration Subscriptions
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=    Load Test Sample    ${subscription_payload_file_path}    ${subscription_id}
    Create Context Source Registration Subscription    ${subscription_payload}
    Set Suite Variable    ${subscription_id}
    Set Suite Variable    ${subscription_payload}

Delete Initial Context Source Registration Subscriptions
    Delete Context Source Registration Subscription    ${subscription_id}
