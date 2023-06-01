*** Settings ***
Documentation       Check that you cannot update a subscription: If expiresAt is included but referring to a DateTime in the past, then a BadRequestData error shall be raised

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Setup Initial Subscriptions
Suite Teardown      Delete Initial Subscriptions


*** Variables ***
${subscription_id_prefix}=                      urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=              subscriptions/subscription-sample.jsonld
${subscription_update_fragment_file_path}=      subscriptions/fragments/subscription-expiresAt-update-sample.json


*** Test Cases ***
Update Subscription With ExpiresAt In The Past
    [Documentation]    Check that you cannot update a subscription: If expiresAt is included but referring to a DateTime in the past, then a BadRequestData error shall be raised
    [Tags]    sub-update    5_8_2
    ${response}=    Update Subscription
    ...    ${subscription_id}
    ...    ${subscription_update_fragment_file_path}
    ...    ${CONTENT_TYPE_JSON}
    Check Response Status Code    400    ${response.status_code}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()}
    ...    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}



*** Keywords ***
Setup Initial Subscriptions
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    Create Subscription    ${subscription_id}    ${subscription_payload_file_path}    ${CONTENT_TYPE_LD_JSON}
    Set Suite Variable    ${subscription_id}

Delete Initial Subscriptions
    Delete Subscription    ${subscription_id}
