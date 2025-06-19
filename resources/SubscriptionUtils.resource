*** Settings ***
Documentation       Common keywords used in setup steps for subscriptions

Resource            ${EXECDIR}/resources/ApiUtils/Common.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationSubscription.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource


*** Keywords ***
Create Subscription And Entity
    [Arguments]    ${subscription_payload_file_path}    ${building_filename}

    ${entity_id}=    Generate Random Building Entity Id
    Set Suite Variable    ${entity_id}
    ${create_entity_response}=    Create Entity Selecting Content Type
    ...    ${building_filename}
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${create_entity_response.status_code}

    ${subscription_id}=    Generate Random Subscription Id
    Set Suite Variable    ${subscription_id}
    ${subscription_payload}=    Load Subscription Sample With Reachable Endpoint
    ...    ${subscription_payload_file_path}
    ...    ${subscription_id}
    ${create_subscription_response}=    Create Subscription From Subscription Payload
    ...    ${subscription_payload}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${create_subscription_response.status_code}
