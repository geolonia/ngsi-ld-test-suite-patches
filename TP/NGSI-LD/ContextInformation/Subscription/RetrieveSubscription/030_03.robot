*** Settings ***
Documentation   Check that you can retrieve a subscription
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Suite Setup      Setup Initial Subscriptions
Suite Teardown      Delete Initial Subscriptions

*** Variable ***
${subscription_id_prefix}=  urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=   subscriptions/subscription-sample.jsonld
${expectation_file_path}=   subscriptions/expectations/subscriptions-030-03-expectation.json

*** Test Case ***
Retrieve Subscription
    [Documentation]  Check that you can retrieve a subscription
    [Tags]   sub-retrieve    5_8_3

    Retrieve Subscription   ${subscription_id}     context=${ngsild_test_suite_context}

    Check Response Status Code Set To  200
    Check Response Body Containing Subscription element     ${expectation_file_path}   ${subscription_id}

*** Keywords ***
Setup Initial Subscriptions
    ${subscription_id}=     Generate Random Entity Id    ${subscription_id_prefix}

    Create Subscription  ${subscription_id}     ${subscription_payload_file_path}   ${CONTENT_TYPE_LD_JSON}

    Set Suite Variable  ${subscription_id}

Delete Initial Subscriptions
    Delete Subscription     ${subscription_id}
