*** Settings ***
Documentation   Check that you cannot update a subscription: Any attempt to remove (by setting them to null in the Fragment) mandatory properties of a Subscription (clause 5.2.12) shall result in an error of type BadRequestData
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Suite Setup      Setup Initial Subscriptions
Suite Teardown      Delete Initial Subscriptions

*** Variable ***
${subscription_id_prefix}=  urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=   subscriptions/subscription-sample.jsonld
${subscription_update_fragment_file_path}=   subscriptions/fragments/subscription-null-properties-update-sample.json

*** Test Case ***
Update Subscription With Null Mandatory Properties
    [Documentation]  Check that you cannot update a subscription: Any attempt to remove (by setting them to null in the Fragment) mandatory properties of a Subscription (clause 5.2.12) shall result in an error of type BadRequestData
    [Tags]  mandatory

    Update Subscription   ${subscription_id}     ${subscription_update_fragment_file_path}   ${CONTENT_TYPE_JSON}

    Check Response Status Code Set To  400
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}

*** Keywords ***
Setup Initial Subscriptions
    ${subscription_id}=     Generate Random Entity Id    ${subscription_id_prefix}

    Create Subscription  ${subscription_id}     ${subscription_payload_file_path}   ${CONTENT_TYPE_LD_JSON}

    Set Suite Variable  ${subscription_id}

Delete Initial Subscriptions
    Delete Subscription     ${subscription_id}
