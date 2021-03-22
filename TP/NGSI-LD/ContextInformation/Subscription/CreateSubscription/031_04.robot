*** Settings ***
Documentation   Check that you cannot create a subscription with an existing id
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${subscription_id_prefix}=  urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=   subscriptions/subscription-sample.jsonld

*** Test Case ***
Create a subscription with an id known to the system
    [Documentation]  Check that you cannot create a subscription with an existing id
    [Tags]   /entities/    5_6_1

    ${subscription_id}=     Generate Random Entity Id    ${subscription_id_prefix}
    Create Subscription  ${subscription_id}     ${subscription_payload_file_path}    ${CONTENT_TYPE_LD_JSON}
    
    ${response}=  Create Subscription  ${subscription_id}     ${subscription_payload_file_path}    ${CONTENT_TYPE_LD_JSON}

    Check Response Status Code  409    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_ALREADY_EXISTS}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}

    [Teardown]    Delete Subscription     ${subscription_id}

