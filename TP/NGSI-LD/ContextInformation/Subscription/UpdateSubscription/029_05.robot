*** Settings ***
Documentation   Check that you can update a subcription: Term to URI expansion of Attribute names shall be observed
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Suite Setup      Setup Initial Subscriptions
Suite Teardown      Delete Initial Subscriptions

*** Variable ***
${subscription_id_prefix}=  urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=   subscriptions/subscription-sample.jsonld
${subscription_update_fragment_file_path}=   subscriptions/fragments/subscription-vehicle-entities-sample.json
${expected_subscription_payload_file_path}=   subscriptions/expectations/subscription-vehicle-sample.jsonld
${expected_expanded_subscription_payload_file_path}=   subscriptions/expectations/subscription-vehicle-expanded-types-sample.jsonld

*** Test Case ***
Update Subscription With Term to Uri Expansion
    [Documentation]  Check that you can update a subcription: Term to URI expansion of Attribute names shall be observed
    [Tags]  mandatory

    Update Subscription   ${subscription_id}     ${subscription_update_fragment_file_path}   ${CONTENT_TYPE_JSON}   context=${ngsild_test_suite_context}

    Check Response Status Code Set To  204

    Retrieve Subscription   ${subscription_id}  context=${ngsild_test_suite_context}
    Check Response Body Containing Subscription element     ${expected_subscription_payload_file_path}   ${subscription_id}

    Retrieve Subscription   ${subscription_id}
    Check Response Body Containing Subscription element     ${expected_expanded_subscription_payload_file_path}   ${subscription_id}

*** Keywords ***
Setup Initial Subscriptions
    ${subscription_id}=     Generate Random Entity Id    ${subscription_id_prefix}

    Create Subscription  ${subscription_id}     ${subscription_payload_file_path}   ${CONTENT_TYPE_LD_JSON}

    Set Suite Variable  ${subscription_id}

Delete Initial Subscriptions
    Delete Subscription     ${subscription_id}
