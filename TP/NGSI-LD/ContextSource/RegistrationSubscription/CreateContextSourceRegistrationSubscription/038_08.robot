*** Settings ***
Documentation       Check that you cannot create a context source registration subscription If the data types, cardinalities and restrictions expressed by clause 5.2.12 are not met

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Template       Create Invalid Context Source Registration Subscription


*** Variables ***
${subscription_id_prefix}=              urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=      ${EMPTY}


*** Test Cases ***    FILEPATH
038_08_01 WithoutNotification
    [Tags]    csrsub-create    5_11_2
    csourceSubscriptions/subscription-without-notification-sample.jsonld
038_08_02 InvalidType
    [Tags]    csrsub-create    5_11_2
    csourceSubscriptions/subscription-invalid-type-sample.jsonld
038_08_03 InvalidQuery
    [Tags]    csrsub-create    5_11_2
    csourceSubscriptions/subscription-invalid-query-sample.jsonld
038_08_04 EmptyWatchedAttributes
    [Tags]    csrsub-create    5_11_2
    csourceSubscriptions/subscription-empty-watchedAttributes-sample.jsonld


*** Keywords ***
Create Invalid Context Source Registration Subscription
    [Documentation]    Check that you cannot create a context source registration subscription If the data types, cardinalities and restrictions expressed by clause 5.2.12 are not met
    [Arguments]    ${filepath}
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=    Load Test Sample    ${filepath}    ${subscription_id}
    ${response}=    Create Context Source Registration Subscription    ${subscription_payload}
    Check Response Status Code    400    ${response.status_code}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()}
    ...    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}
