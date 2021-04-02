*** Settings ***
Documentation   Check that you cannot create a context source registration subscription If the data types, cardinalities and restrictions expressed by clause 5.2.12 are not met
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Create Invalid Context Source Registration Subscription

*** Variable ***
${subscription_id_prefix}=  urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=

*** Test Cases ***                        FILEPATH
WithoutNotification                       csourceSubscriptions/subscription-without-notification-sample.jsonld
    [Tags]   csrsub-create    5_11_2
InvalidType                               csourceSubscriptions/subscription-invalid-type-sample.jsonld
    [Tags]   csrsub-create    5_11_2
InvalidQuery                              csourceSubscriptions/subscription-invalid-query-sample.jsonld
    [Tags]   csrsub-create    5_11_2
EmptyWatchedAttributes                    csourceSubscriptions/subscription-empty-watchedAttributes-sample.jsonld
    [Tags]   csrsub-create    5_11_2

*** Keywords ***
Create Invalid Context Source Registration Subscription
    [Arguments]  ${filepath}
    [Documentation]  Check that you cannot create a context source registration subscription If the data types, cardinalities and restrictions expressed by clause 5.2.12 are not met

    ${subscription_id}=     Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=  Load Test Sample    ${filepath}    ${subscription_id}

    Create Context Source Registration Subscription  ${subscription_payload}

    Check Response Status Code Set To  400
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}
