*** Settings ***
Documentation       Check that one can retrieve a context source registration subscription

Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistrationSubscription.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Setup Initial Context Source Registration Subscription
Test Teardown       Delete Created Context Source Registration Subscription


*** Variables ***
${subscription_id_prefix}=              urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=      csourceSubscriptions/subscription-sample.jsonld
${expectation_file_path}=               csourceSubscriptions/expectations/subscriptions-040-01-expectation.json


*** Test Cases ***
040_01_01 Retrieve Context Source Registration Subscription
    [Documentation]    Check that one can retrieve a context source registration subscription
    [Tags]    csrsub-retrieve    5_11_4
    ${response}=    Retrieve Context Source Registration Subscription
    ...    subscription_id=${subscription_id}
    ...    context=${ngsild_test_suite_context}

    ${expected_link_header}=    CATENATE
    ...    SEPARATOR=
    ...    <
    ...    ${ngsild_test_suite_context}
    ...    >; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"

    Check Response Status Code    200    ${response.status_code}
    Check Response Reason set to    ${response.reason}    OK
    Check Response Headers Link set to
    ...    response_headers=${response.headers}
    ...    expected_link_header=${expected link header}

    ${expectation_payload}=    Load Test Sample    ${expectation_file_path}    ${subscription_id}

    # One needs to ignore the Additional Members ('lastFailure', 'lastNotification', 'timesFailed', 'timesSent', 'isActive')
    ${ignored_attributes}=    Create List
    ...    ${status_regex_expr}
    ...    ${lastfailure_regex_expr}
    ...    ${lastNotification_regex_expr}
    ...    ${timesFailed_regex_expr}
    ...    ${timesSent_regex_expr}
    ...    ${is_active_expr}

    Check Created Resource Set To
    ...    created_resource=${expectation_payload}
    ...    response_body=${response.json()}
    ...    ignored_keys=${ignored_attributes}

    Check Response Body Might Contain Additional Members of the NotificationParams
    ...    ${response.json()}
    ...    lastNotification
    Check Response Body Might Contain Additional Members of the NotificationParams    ${response.json()}    lastFailure
    Check Response Body Might Contain Additional Members of the NotificationParams    ${response.json()}    lastSuccess
    Check Response Body Might Contain Additional Members of the NotificationParams    ${response.json()}    timesSent


*** Keywords ***
Setup Initial Context Source Registration Subscription
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=    Load Test Sample    ${subscription_payload_file_path}    ${subscription_id}
    Create Context Source Registration Subscription    ${subscription_payload}
    Set Suite Variable    ${subscription_id}

Delete Created Context Source Registration Subscription
    Delete Context Source Registration Subscription    ${subscription_id}
