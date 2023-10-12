*** Settings ***
Documentation       Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header is "application/geo+json" for operations different than "Retrieve Entity" and "Query Entity"

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource


*** Variables ***
${accept}=                      application/geo+json
${status_code}=                 406
${subscription_id_prefix}=      urn:ngsi-ld:Subscription:
${subscription_filename}=       csourceSubscriptions/subscription-sample.jsonld


*** Test Cases ***
044_05_01 Retrieve subscription by id
    [Documentation]    Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header does not imply "application/json" nor "application/ld+json" (get /subscriptions/{subscriptionId})
    [Tags]    sub-retrieve    6_3_4
    ${id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${response}=    Create Subscription    ${id}    ${subscription_filename}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Retrieve Subscription
    ...    id=${id}
    ...    accept=${accept}
    Check Response Status Code    ${status_code}    ${response.status_code}
    [Teardown]    Delete Subscription    ${id}

044_05_02 Query temporal entities
    [Documentation]    Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header does not imply "application/json" nor "application/ld+json" (get /temporal/entities)
    [Tags]    te-query    6_3_4
    ${entity_types_to_be_retrieved}=    Catenate    SEPARATOR=,    Vehicle
    ${response}=    Query Temporal Representation Of Entities
    ...    entity_types=${entity_types_to_be_retrieved}
    ...    timerel=after
    ...    timeAt=2020-08-01T12:05:00Z
    ...    accept=${accept}
    Check Response Status Code    ${status_code}    ${response.status_code}

044_05_03 Query context source registration
    [Documentation]    Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header does not imply "application/json" nor "application/ld+json" (get /csourceRegistrations)
    [Tags]    csr-query    6_3_4
    ${response}=    Query Context Source Registrations With Return    type=Building    accept=${accept}
    Check Response Status Code    ${status_code}    ${response.status_code}
