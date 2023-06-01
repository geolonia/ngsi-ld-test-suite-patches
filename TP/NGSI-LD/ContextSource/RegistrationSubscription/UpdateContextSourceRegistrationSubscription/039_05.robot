*** Settings ***
Documentation       Check that you cannot update a context source registration subscription with an invalid request body (invalid JSON document)

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Setup Initial Context Source Registration Subscriptions
Suite Teardown      Delete Initial Context Source Registration Subscriptions


*** Variables ***
${subscription_id_prefix}=                      urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=              csourceSubscriptions/subscription-sample.jsonld
${subscription_update_fragment_file_path}=      csourceSubscriptions/fragments/subscription-update-invalid-json-sample.json


*** Test Cases ***
Update Context Source Registration Subscription With Invalid JSON Fragment
    [Documentation]    Check that you cannot update a context source registration subscription with an invalid request body (invalid JSON document)
    [Tags]    csrsub-update    5_11_3
    ${response}=    Update Context Source Registration Subscription From File
    ...    ${subscription_id}
    ...    ${subscription_update_fragment_file_path}
    Check Response Status Code    400    ${response.status_code}
    Check RL Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()}
    ...    ${ERROR_TYPE_INVALID_REQUEST}
    Check RL Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}


*** Keywords ***
Setup Initial Context Source Registration Subscriptions
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=    Load Test Sample    ${subscription_payload_file_path}    ${subscription_id}
    Create Context Source Registration Subscription    ${subscription_payload}
    Set Suite Variable    ${subscription_id}

Delete Initial Context Source Registration Subscriptions
    Delete Context Source Registration Subscription    ${subscription_id}
