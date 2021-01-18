*** Settings ***
Documentation   Check that you can delete a context source registration subscription
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Suite Setup      Setup Initial Context Source Registration Subscriptions

*** Variable ***
${subscription_id_prefix}=  urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=   csourceSubscriptions/subscription-sample.jsonld

*** Test Case ***
Delete Context Source Registration Subscription
    [Documentation]  Check that you can delete a context source registration subscription
    [Tags]  mandatory

    Delete Context Source Registration Subscription  ${subscription_id}

    Check Response Status Code Set To  204

*** Keywords ***
Setup Initial Context Source Registration Subscriptions
    ${subscription_id}=     Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=  Load Test Sample    ${subscription_payload_file_path}    ${subscription_id}

    Create Context Source Registration Subscription  ${subscription_payload}

    Set Suite Variable  ${subscription_id}
