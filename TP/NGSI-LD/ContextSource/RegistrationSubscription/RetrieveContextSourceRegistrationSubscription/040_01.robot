*** Settings ***
Documentation   Check that you can retrieve a context source registration subscription
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Suite Setup      Setup Initial Context Source Registration Subscription
Suite Teardown      Delete Created Context Source Registration Subscription

*** Variable ***
${subscription_id_prefix}=  urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=   csourceSubscriptions/subscription-sample.jsonld
${expectation_file_path}=   csourceSubscriptions/expectations/subscriptions-040-01-expectation.json

*** Test Case ***
Retrieve Context Source Registration Subscription
    [Documentation]  Check that you can retrieve a context source registration subscription
    [Tags]   csrsub-retrieve    5_11_4

    Retrieve Context Source Registration Subscription  ${subscription_id}   context=${ngsild_test_suite_context}

    Check Response Status Code Set To  200
    Check Response Body Containing Subscription element     ${expectation_file_path}   ${subscription_id}

*** Keywords ***
Setup Initial Context Source Registration Subscription
    ${subscription_id}=     Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=  Load Test Sample    ${subscription_payload_file_path}    ${subscription_id}

    Create Context Source Registration Subscription  ${subscription_payload}

    Set Suite Variable  ${subscription_id}

Delete Created Context Source Registration Subscription
    Delete Context Source Registration Subscription     ${subscription_id}
