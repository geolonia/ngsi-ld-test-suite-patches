*** Settings ***
Documentation     Check that you cannot create a context source registration subscription with an expiration timestamp representing a moment before the current date and time
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${subscription_id_prefix}=    urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=    csourceSubscriptions/subscription-expired-sample.jsonld

*** Test Case ***
Create Expired Context Source Registration Subscription
    [Documentation]    Check that you cannot create a context source registration subscription with an expiration timestamp representing a moment before the current date and time
    [Tags]    csrsub-create    5_11_2
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=    Load Test Sample    ${subscription_payload_file_path}    ${subscription_id}
    Create Context Source Registration Subscription    ${subscription_payload}
    Check Response Status Code Set To    400
    Check Response Body Containing ProblemDetails Element Containing Type Element set to    ${response}    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}
