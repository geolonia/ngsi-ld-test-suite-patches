*** Settings ***
Documentation     Verify that on a GET HTTP request if nothing is specified on the Accept header, "application/json" is assumed
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${building_id_prefix}=    urn:ngsi-ld:Building:
${building_filename}=    building-simple-attributes-sample.jsonld
${building_expectation}=    building-simple-attributes-sample-expectation.json
${entity_type}=    https://ngsi-ld-test-suite/context#Building
${subscription_id_prefix}=    urn:ngsi-ld:Subscription:
${subscription_filename}=    subscriptions/subscription-sample.jsonld
${subscription_expectation}=    subscription-sample-expectation.json
${registration_id_prefix}=    urn:ngsi-ld:Registration:
${registration_filename}=    csourceRegistrations/context-source-registration-with-expiration-sample.jsonld
${registration_expectation}=    context-source-registration-with-expiration-expectation.json
${registration_type}=    Vehicle
${tea_id_prefix}=    urn:ngsi-ld:Vehicle:
${tea_filename}=    vehicle-temporal-representation-sample.jsonld
${tea_expectation}=    vehicles-temporal-representation-044-02-04-expectation.json
${teatype}=       Vehicle
${content_type}=    application/json

*** Test Cases ***
044_02_01_endpoint /entities/{entityId}
    [Documentation]    Verify that on a GET HTTP request if nothing is specified on the Accept header, "application/json" is assumed (/entities/{entityId})
    [Tags]    e-query    6_3_4
    ${id}=    Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type    ${building_filename}    ${id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response['status']}
    ${request}    ${response}=    Query Entity    ${id}    context=${ngsild_test_suite_context}    accept=*/*
    Check Response Status Code    200    ${response['status']}
    Check Response Body Containing Entity element    ${building_expectation}    ${id}    ${response['body']}
    Check Response Headers Containing Content-Type set to    ${response}    ${content_type}
    Check Response Headers Link Not Empty    ${response}
    [Teardown]    Delete Entity by Id Returning Response    ${id}

044_02_02_endpoint /subscriptions/{subscriptionId}
    [Documentation]    Verify that on a GET HTTP request if nothing is specified on the Accept header, "application/json" is assumed (/subscriptions/{subscriptionId})
    [Tags]    sub-retrieve    6_3_4
    ${id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${response}=    Create Subscription    ${id}    ${subscription_filename}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response['status']}
    ${request}    ${response}=    Retrieve Subscription    ${id}    accept=*/*
    Check Response Status Code    200    ${response['status']}
    Check Response Body Containing One Subscription element    ${subscription_expectation}    ${response['body']}
    Check Response Headers Containing Content-Type set to    ${response}    ${content_type}
    Check Response Headers Link Not Empty    ${response}
    [Teardown]    Delete Subscription    ${id}

044_02_03_endpoint /csourceRegistrations/
    [Documentation]    Verify that on a GET HTTP request if nothing is specified on the Accept header, "application/json" is assumed (/csourceRegistrations/)
    [Tags]    csr-query    6_3_4
    ${registration_id}=    Generate Random Entity Id    ${registration_id_prefix}
    ${payload}=    Load Json From File    ${EXECDIR}/data/${registration_filename}
    ${updated_payload}=    Update Value To Json    ${payload}    $..id    ${registration_id}
    ${request}    ${response}=    Create Context Source Registration With Return    ${updated_payload}
    Check Response Status Code    201    ${response['status']}
    ${request}    ${response}=    Query Context Source Registrations With Return    id=${registration_id}    type=${registration_type}    context=${ngsild_test_suite_context}    accept=*/*
    Check Response Status Code    200    ${response['status']}
    Check Response Body Containing One Registration element    ${registration_expectation}    ${response['body']}
    Check Response Headers Containing Content-Type set to    ${response}    ${content_type}
    Check Response Headers Link Not Empty    ${response}
    [Teardown]    Delete Context Source Registration    ${registration_id}

044_02_04_endpoint /temporal/entities
    [Documentation]    Verify that on a GET HTTP request if nothing is specified on the Accept header, "application/json" is assumed (/temporal/entities)
    [Tags]    te-query    6_3_4
    ${temporal_entity_representation_id}=    Generate Random Entity Id    ${tea_id_prefix}
    Create Temporal Representation Of Entity    ${tea_filename}    ${temporal_entity_representation_id}
    Check Response Status Code    201    ${response['status']}
    ${request}    ${response}=    Query Temporal Representation Of Entities With Return    entity_types=${teatype}    timerel=after    timeAt=2020-08-01T12:05:00Z    context=${ngsild_test_suite_context}    accept=*/*
    Check Response Status Code    200    ${response['status']}
    Set Test Variable    ${response}
    Check Response Body Containing EntityTemporal element    ${tea_expectation}    ${temporal_entity_representation_id}
    Check Response Headers Containing Content-Type set to    ${response}    ${content_type}
    Check Response Headers Link Not Empty    ${response}
    [Teardown]    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
