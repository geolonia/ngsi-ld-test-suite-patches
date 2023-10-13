*** Settings ***
Documentation       Check that you can create a minimal context source registration subscription

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Generate Random Ids For Context Source Registration Subscriptions
Suite Teardown      Delete Created Context Source Registration Subscriptions


*** Variables ***
${subscription_id_prefix}=              urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=      csourceSubscriptions/subscription-sample.jsonld


*** Test Cases ***
038_01_01 Create Context Source Registration Subscription
    [Documentation]    Check that you can create a minimal context source registration subscription
    [Tags]    csrsub-create    5_11_2
    ${subscription_payload}=    Load Test Sample    ${subscription_payload_file_path}    ${subscription_id}
    ${response}=    Create Context Source Registration Subscription    ${subscription_payload}
    Check Response Status Code    201    ${response.status_code}
    Check Response Headers Containing URI set to    ${subscription_id}    ${response.headers}
    ${response}=    Retrieve Context Source Registration Subscription
    ...    subscription_id=${subscription_id}
    ...    context=${ngsild_test_suite_context}
    ...    accept=${CONTENT_TYPE_LD_JSON}
    ${ignored_attributes}=    Create List    ${status_regex_expr}
    Check Created Resource Set To    ${subscription_payload}    ${response.json()}    ${ignored_attributes}


*** Keywords ***
Generate Random Ids For Context Source Registration Subscriptions
    # TODO: Refactor Generate Random Entity Id to Generate Random Test Sample Id
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    Set Suite Variable    ${subscription_id}

Delete Created Context Source Registration Subscriptions
    Delete Context Source Registration Subscription    ${subscription_id}
