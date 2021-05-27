*** Settings ***
Documentation     If a Subscription defines a timeInterval member, a Notification shall be sent periodically, when the time interval (in seconds) specified in such value field is reached, regardless of Attribute changes."
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Resource          ${EXECDIR}/resources/NotificationUtils.resource
Suite Setup       Setup Initial Subscriptions
Suite Teardown    Delete Initial Subscriptions

*** Variable ***
${subscription_id_prefix}=    urn:ngsi-ld:Subscription:
${subscription_payload_file_path}= subscriptions/subscription-timeinterval-sample.jsonld
${building_id_prefix}=    urn:ngsi-ld:Building:




*** Test Case ***
Check that a notification is send on the timeinterval
    [Arguments]      ${fragment_filename}    
    [Documentation]     If a Subscription defines a timeInterval member, a Notification shall be sent periodically, when the time interval (in seconds) specified in such value field is reached, regardless of Attribute changes."
    [Tags]    sub-notification    5_11_7
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=    Load Subscription Sample With Reachable Endpoint    ${subscription_payload_file_path}    ${subscription_id}
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Suite Variable    ${subscription_id}
    Wait for notification  timeout=${15}





