*** Settings ***
Documentation     If a Subscription does not define a timeInterval term, the notification shall be sent whenever there is a change in the watched Attributes. The notification message shall include all the subscribed Entities that changed and that match (as mandated by clauses 4.9 and4.10) the query and geoquery conditions

Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Resource          ${EXECDIR}/resources/NotificationUtils.resource
Suite Setup       Setup Initial Subscriptions
Suite Teardown    Delete Initial Subscriptions

*** Variable ***
${subscription_id_prefix}=    urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=    subscriptions/subscription-building-entities-active-query.jsonld
${building_id_prefix}=    urn:ngsi-ld:Building:
${building_filename}=    building-location-attribute.jsonld





*** Test Case ***
Check that a notification is send with all entities
    [Arguments]      ${fragment_filename}    
    [Documentation]     The notification message shall include all the subscribed Entities that changed and that match (as mandated by clauses 4.9 and4.10) the query and geoquery conditions
    [Tags]    sub-notification    5_11_7
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=    Load Subscription Sample With Reachable Endpoint    ${subscription_payload_file_path}    ${subscription_id}
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    ${entity_building}   Create Entity Selecting Content Type    ${building_filename}    ${entity_id}    ${CONTENT_TYPE_LD_JSON}

    Set Suite Variable    ${subscription_id}
    Wait for subscription notification and validate it  ${subscription_id}  ${entity}  timeout=${5}





