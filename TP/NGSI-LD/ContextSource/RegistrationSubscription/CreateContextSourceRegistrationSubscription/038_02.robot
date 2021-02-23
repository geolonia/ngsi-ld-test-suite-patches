*** Settings ***
Documentation   Check that you can create a context source registration subscription without providing an id and it will be automatically generated
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource
Resource    ${EXECDIR}/resources/HttpUtils.resource

Suite Teardown      Delete Created Context Source Registration Subscriptions

*** Variable ***
${subscription_payload_file_path}=   csourceSubscriptions/subscription-sample.jsonld

*** Test Case ***
Create Context Source Registration Subscription Without An Id
    [Documentation]  Check that you can create a context source registration subscription without providing an id and it will be automatically generated
    [Tags]  mandatory

    ${subscription_payload}=  Load Test Sample    ${subscription_payload_file_path}

    Create Context Source Registration Subscription  ${subscription_payload}

    ${subscription_id}=     Fetch Id From Response Location Header
    Check Response Status Code Set To  201
    Check Response Headers Containing URI set to    ${request['path']}/    ${subscription_id}  ${response}

    Set Suite Variable  ${subscription_id}

*** Keywords ***
Delete Created Context Source Registration Subscriptions
    Delete Context Source Registration Subscription     ${subscription_id}
