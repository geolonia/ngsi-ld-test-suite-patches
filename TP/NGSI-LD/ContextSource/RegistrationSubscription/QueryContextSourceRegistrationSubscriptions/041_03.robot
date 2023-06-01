*** Settings ***
Documentation       Check that you can query context source registration subscriptions with providing page and limit parameters for pagination

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Setup Initial Context Source Registration Subscriptions
Suite Teardown      Delete Created Context Source Registration Subscriptions
Test Template       Query Context Source Registration Subscriptions With Limit And Page Parameters


*** Variables ***
${subscription_id_prefix}=                      urn:ngsi-ld:Subscription:
${first_subscription_payload_file_path}=        csourceSubscriptions/subscription-sample.jsonld
${second_subscription_payload_file_path}=       csourceSubscriptions/subscription-watchedAttributes-sample.jsonld
${third_subscription_payload_file_path}=        csourceSubscriptions/subscription-geoQ-sample.jsonld


*** Test Cases ***    LIMIT    PAGE    EXPECTED_SUBSCRIPTION_NUMBER    PREV_LINK    NEXT_LINK
Query Second Subscription
    [Tags]    csrsub-query    5_11_5
    ${1}    ${2}    ${1}    </ngsi-ld/v1/csourceSubscriptions?limit=1&page=1>;rel="prev";type="application/ld+json"    </ngsi-ld/v1/csourceSubscriptions?limit=1&page=3>;rel="next";type="application/ld+json"
Query Last Subscription
    [Tags]    csrsub-query    5_11_5
    ${2}    ${2}    ${1}    </ngsi-ld/v1/csourceSubscriptions?limit=2&page=1>;rel="prev";type="application/ld+json"    ${EMPTY}
Query All Subscriptions
    [Tags]    csrsub-query    5_11_5
    ${15}    ${1}    ${3}    ${EMPTY}    ${EMPTY}


*** Keywords ***
Query Context Source Registration Subscriptions With Limit And Page Parameters
    [Documentation]    Check that you can query context source registration subscriptions with providing page and limit parameters for pagination
    [Arguments]    ${limit}    ${page}    ${expectation_subscription_number}    ${prev_link}    ${next_link}
    ${response}=    Query Context Source Registration Subscriptions
    ...    context=${ngsild_test_suite_context}
    ...    limit=${limit}
    ...    page=${page}
    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing Number Of Entities
    ...    Subscription
    ...    ${expectation_subscription_number}
    ...    ${response.json()}
    Check Pagination Prev And Next Headers    ${prev_link}    ${next_link}    ${response.json()}

Setup Initial Context Source Registration Subscriptions
    ${first_subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${second_subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${third_subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${first_subscription_payload}=    Load Test Sample
    ...    ${first_subscription_payload_file_path}
    ...    ${first_subscription_id}
    ${second_subscription_payload}=    Load Test Sample
    ...    ${second_subscription_payload_file_path}
    ...    ${second_subscription_id}
    ${third_subscription_payload}=    Load Test Sample
    ...    ${third_subscription_payload_file_path}
    ...    ${third_subscription_id}
    Create Context Source Registration Subscription    ${first_subscription_payload}
    Create Context Source Registration Subscription    ${second_subscription_payload}
    Create Context Source Registration Subscription    ${third_subscription_payload}
    Set Suite Variable    ${first_subscription_id}
    Set Suite Variable    ${second_subscription_id}
    Set Suite Variable    ${third_subscription_id}

Delete Created Context Source Registration Subscriptions
    Delete Context Source Registration Subscription    ${first_subscription_id}
    Delete Context Source Registration Subscription    ${second_subscription_id}
    Delete Context Source Registration Subscription    ${third_subscription_id}
