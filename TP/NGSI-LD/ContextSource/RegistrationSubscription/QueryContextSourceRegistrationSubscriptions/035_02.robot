*** Settings ***
Documentation   Check that you can query context source registration subscriptions with a limit parameter and it will be the maximum number of subscriptions to be retrieved
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Query Context Source Registration Subscriptions With Limit Parameter
Suite Setup      Setup Initial Context Source Registration Subscriptions
Suite Teardown      Delete Created Context Source Registration Subscriptions

*** Variable ***
${subscription_id_prefix}=  urn:ngsi-ld:Subscription:
${first_subscription_payload_file_path}=   csourceSubscriptions/subscription-sample.jsonld
${second_subscription_payload_file_path}=   csourceSubscriptions/subscription-watchedAttributes-sample.jsonld
${third_subscription_payload_file_path}=   csourceSubscriptions/subscription-geoQ-sample.jsonld
${expectation_file_path}=   csourceSubscriptions/expectations/subscriptions-035-01-expectation.json

*** Test Cases ***                        LIMIT         EXPECTED_SUBSCRIPTION_NUMBER
Query One Subscription                    ${1}          ${1}
Query Two Subscription                    ${2}          ${2}
Query All Subscriptions                   ${15}         ${3}

*** Keywords ***
Query Context Source Registration Subscriptions With Limit Parameter
    [Arguments]  ${limit}     ${expectation_subscription_number}

    [Documentation]  Check that you can query context source registration subscriptions with a limit parameter and it will be the maximum number of subscriptions to be retrieved
    [Tags]  mandatory

    Query Context Source Registration Subscriptions  context=${ngsild_test_suite_context}   limit=${limit}

    Check Response Status Code Set To  200
    Check Response Body Containing Number Of Entities   Subscription     ${expectation_subscription_number}

Setup Initial Context Source Registration Subscriptions
    ${first_subscription_id}=     Generate Random Entity Id    ${subscription_id_prefix}
    ${second_subscription_id}=     Generate Random Entity Id    ${subscription_id_prefix}
    ${third_subscription_id}=     Generate Random Entity Id    ${subscription_id_prefix}
    ${first_subscription_payload}=  Load Test Sample    ${first_subscription_payload_file_path}    ${first_subscription_id}
    ${second_subscription_payload}=  Load Test Sample    ${second_subscription_payload_file_path}    ${second_subscription_id}
    ${third_subscription_payload}=  Load Test Sample    ${third_subscription_payload_file_path}    ${third_subscription_id}

    Create Context Source Registration Subscription  ${first_subscription_payload}
    Create Context Source Registration Subscription  ${second_subscription_payload}
    Create Context Source Registration Subscription  ${third_subscription_payload}

    Set Suite Variable  ${first_subscription_id}
    Set Suite Variable  ${second_subscription_id}
    Set Suite Variable  ${third_subscription_id}

Delete Created Context Source Registration Subscriptions
    Delete Context Source Registration Subscription     ${first_subscription_id}
    Delete Context Source Registration Subscription     ${second_subscription_id}
    Delete Context Source Registration Subscription     ${third_subscription_id}
