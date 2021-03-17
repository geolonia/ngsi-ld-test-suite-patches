*** Settings ***
Documentation   Check that you can update a subscription: If only expiresAt is included and refers to a DateTime in the future or is null, then status shall be updated to "active", if and only if the previous value of status was "expired"
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Suite Setup      Setup Initial Subscriptions
Suite Teardown      Delete Initial Subscriptions

*** Variable ***
${subscription_id_prefix}=  urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=   subscriptions/subscription-inactive-sample.jsonld
${subscription_update_fragment_file_path}=   subscriptions/fragments/subscription-expiresAt-future-update-sample.json

*** Test Case ***
Activate Expired Subscription
    [Documentation]  Check that you can update a subscription: If only expiresAt is included and refers to a DateTime in the future or is null, then status shall be updated to "active", if and only if the previous value of status was "expired"
    [Tags]  mandatory

    # Update subscription to expired
    Update Subscription   ${subscription_id}     subscriptions/fragments/subscription-expiresAt-update-sample.json   ${CONTENT_TYPE_JSON}

    Update Subscription   ${subscription_id}     ${subscription_update_fragment_file_path}   ${CONTENT_TYPE_JSON}

    Check Response Status Code Set To  204
    Retrieve Subscription   ${subscription_id}
    Check Response Body Containing an Attribute set to   status   active

*** Keywords ***
Setup Initial Subscriptions
    ${subscription_id}=     Generate Random Entity Id    ${subscription_id_prefix}

    Create Subscription  ${subscription_id}     ${subscription_payload_file_path}   ${CONTENT_TYPE_LD_JSON}

    Set Suite Variable  ${subscription_id}

Delete Initial Subscriptions
    Delete Subscription     ${subscription_id}
