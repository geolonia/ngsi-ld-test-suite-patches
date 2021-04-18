*** Settings ***
Documentation     Check that you cannot update an unknown context source registration subscription
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${subscription_update_fragment_file_path}=    csourceSubscriptions/fragments/subscription-update-sample.json

*** Test Case ***
Update Unknown Context Source Registration Subscription
    [Documentation]    Check that you cannot update an unknown context source registration subscription
    [Tags]    csrsub-update    5_11_3
    ${subscription_update_fragment}=    Load Test Sample    ${subscription_update_fragment_file_path}
    Update Context Source Registration Subscription    urn:ngsi-ld:Subscription:unknowSubscription    ${subscription_update_fragment}
    Check Response Status Code Set To    404
    Check Response Body Containing ProblemDetails Element Containing Type Element set to    ${response}    ${ERROR_TYPE_RESOURCE_NOT_FOUND}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}
