*** Settings ***
Documentation   Check that you can create a context source registration subscription without providing isActive member and will be active by default
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Suite Setup      Generate Random Ids For Context Source Registration Subscriptions
Suite Teardown      Delete Created Context Source Registration Subscriptions

*** Variable ***
${subscription_id_prefix}=  urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=   csourceSubscriptions/subscription-sample.jsonld

*** Test Case ***
Create Context Source Registration Subscription Without isActive Member
    [Documentation]  Check that you can create a context source registration subscription without providing isActive member and will be active by default
    [Tags]  mandatory

    ${subscription_payload}=  Load Test Sample    ${subscription_payload_file_path}    ${subscription_id}
    Create Context Source Registration Subscription  ${subscription_payload}
    Check Response Status Code Set To  201
    Check Response Headers Containing URI set to    ${request['path']}/    ${subscription_id}  ${response}
    # TODO: Retrieve context source registration subscription and check status set to active

*** Keywords ***
Generate Random Ids For Context Source Registration Subscriptions
    ${subscription_id}=     Generate Random Entity Id    ${subscription_id_prefix}
    Set Suite Variable  ${subscription_id}

Delete Created Context Source Registration Subscriptions
    Delete Context Source Registration Subscription     ${subscription_id}
