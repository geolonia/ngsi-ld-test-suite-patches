*** Settings ***
Documentation       Check that you can create a context source registration subscription without providing an id and it will be automatically generated

Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistrationSubscription.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource
Resource            ${EXECDIR}/resources/HttpUtils.resource

Suite Teardown      Delete Created Context Source Registration Subscriptions


*** Variables ***
${subscription_payload_file_path}=      csourceSubscriptions/subscription-sample.jsonld


*** Test Cases ***
038_02_01 Create Context Source Registration Subscription Without An Id
    [Documentation]    Check that you can create a context source registration subscription without providing an id and it will be automatically generated
    [Tags]    csrsub-create    5_11_2
    ${subscription_payload}=    Load Test Sample    ${subscription_payload_file_path}
    ${response}=    Create Context Source Registration Subscription    ${subscription_payload}
    ${subscription_id}=    Fetch Id From Response Location Header    ${response.headers}
    Check Response Status Code    201    ${response.status_code}
    Check Response Headers Containing URI set to    ${subscription_id}    ${response.headers}
    Set Suite Variable    ${subscription_id}
    ${response}=    Retrieve Context Source Registration Subscription
    ...    subscription_id=${subscription_id}
    ...    context=${ngsild_test_suite_context}
    ...    accept=${CONTENT_TYPE_LD_JSON}
    ${ignored_attributes}=    Create List    ${id_regex_expr}    ${status_regex_expr}
    Check Created Resource Set To    ${subscription_payload}    ${response.json()}    ${ignored_attributes}


*** Keywords ***
Delete Created Context Source Registration Subscriptions
    Delete Context Source Registration Subscription    ${subscription_id}
