*** Settings ***
Documentation     Check that you can query a list of subscriptions: Pagination logic shall be in place
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Test Template     Query Subscriptions With Limit And Page Parameters
Suite Setup       Setup Initial Subscriptions
Suite Teardown    Delete Initial Subscriptions

*** Variable ***
${subscription_id_prefix}=    urn:ngsi-ld:Subscription:
${first_subscription_payload_file_path}=    subscriptions/subscription-sample.jsonld
${second_subscription_payload_file_path}=    subscriptions/subscription-watchedAttributes-sample.jsonld
${third_subscription_payload_file_path}=    subscriptions/subscription-inactive-sample.jsonld

*** Test Cases ***    LIMIT     OFFSET      EXPECTED_SUBSCRIPTION_NUMBER    PREV_LINK                                                                           NEXT_LINK
Query Second Subscription
                      ${1}      ${1}         ${1}                            </ngsi-ld/v1/subscriptions?limit=1&offset=0>;rel="prev";type="application/ld+json"    </ngsi-ld/v1/subscriptions?limit=1&offset=2>;rel="next";type="application/ld+json"
                      [Tags]    sub-query    5_8_4

Query Last Subscription
                      ${1}      ${2}         ${1}                            </ngsi-ld/v1/subscriptions?limit=1&offset=1>;rel="prev";type="application/ld+json"    ${EMPTY}
                      [Tags]    sub-query    5_8_4

Query All Subscriptions
                      ${15}     ${0}         ${3}                            ${EMPTY}                                                                            ${EMPTY}
                      [Tags]    sub-query    5_8_4

*** Keywords ***
Query Subscriptions With Limit And Page Parameters
    [Arguments]    ${limit}    ${offset}    ${expectation_subscription_number}    ${prev_link}    ${next_link}
    [Documentation]    Check that you can query a list of subscriptions: Pagination logic shall be in place
    Query Subscriptions    context=${ngsild_test_suite_context}    limit=${limit}    offset=${offset}   accept=${CONTENT_TYPE_LD_JSON}
    Check Response Status Code Set To    200
    Check Response Body Containing Number Of Entities    Subscription    ${expectation_subscription_number}
    Check Pagination Prev And Next Headers    ${prev_link}    ${next_link}

Setup Initial Subscriptions
    ${first_subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${second_subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${third_subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    Create Subscription    ${first_subscription_id}    ${first_subscription_payload_file_path}    ${CONTENT_TYPE_LD_JSON}
    Create Subscription    ${second_subscription_id}    ${second_subscription_payload_file_path}    ${CONTENT_TYPE_LD_JSON}
    Create Subscription    ${third_subscription_id}    ${third_subscription_payload_file_path}    ${CONTENT_TYPE_LD_JSON}
    Set Suite Variable    ${first_subscription_id}
    Set Suite Variable    ${second_subscription_id}
    Set Suite Variable    ${third_subscription_id}

Delete Initial Subscriptions
    Delete Subscription    ${first_subscription_id}
    Delete Subscription    ${second_subscription_id}
    Delete Subscription    ${third_subscription_id}
