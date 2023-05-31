*** Settings ***
Documentation       Check that you cannot update a context source registration subscription with a fragment that does not meet the data types and restrictions expressed by clause 5.2.12

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Setup Initial Context Source Registration Subscriptions
Suite Teardown      Delete Initial Context Source Registration Subscriptions
Test Template       Update Context Source Registration Subscription With Invalid Fragment


*** Variables ***
${subscription_id_prefix}=              urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=      csourceSubscriptions/subscription-sample.jsonld


*** Test Cases ***    FILEPATH
InvalidType    [Tags]    csrsub-update    5_11_3
    csourceSubscriptions/fragments/subscription-update-invalid-type-sample.json
InvalidNotification
    [Tags]    csrsub-update    5_11_3
    csourceSubscriptions/fragments/subscription-update-invalid-notification-sample.json


*** Keywords ***
Update Context Source Registration Subscription With Invalid Fragment
    [Documentation]    Check that you cannot update a context source registration subscription with a fragment that does not meet the data types and restrictions expressed by clause 5.2.12
    [Arguments]    ${filepath}
    ${subscription_update_fragment}=    Load Test Sample    ${filepath}
    Update Context Source Registration Subscription    ${subscription_id}    ${subscription_update_fragment}
    Check Response Status Code Set To    400
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response}
    ...    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}

Setup Initial Context Source Registration Subscriptions
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=    Load Test Sample    ${subscription_payload_file_path}    ${subscription_id}
    Create Context Source Registration Subscription    ${subscription_payload}
    Set Suite Variable    ${subscription_id}

Delete Initial Context Source Registration Subscriptions
    Delete Context Source Registration Subscription    ${subscription_id}
