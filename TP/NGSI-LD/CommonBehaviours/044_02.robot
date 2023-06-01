*** Settings ***
Documentation       Verify that on a GET HTTP request if nothing is specified on the Accept header, "application/json" is assumed

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource


*** Variables ***
${building_id_prefix}=          urn:ngsi-ld:Building:
${building_filename}=           building-simple-attributes-sample.jsonld
${subscription_id_prefix}=      urn:ngsi-ld:Subscription:
${subscription_filename}=       subscriptions/subscription-sample.jsonld
${registration_id_prefix}=      urn:ngsi-ld:Registration:
${registration_filename}=       csourceRegistrations/context-source-registration-with-expiration-sample.jsonld
${registration_type}=           Vehicle
${tea_id_prefix}=               urn:ngsi-ld:Vehicle:
${tea_filename}=                vehicle-temporal-representation-sample.jsonld
${teatype}=                     Vehicle
${content_type}=                application/json


*** Test Cases ***
044_02_01_endpoint /entities/{entityId}
    [Documentation]    Verify that on a GET HTTP request if nothing is specified on the Accept header, "application/json" is assumed (/entities/{entityId})
    [Tags]    e-query    6_3_4
    ${id}=    Generate Random Entity Id    ${building_id_prefix}
    ${response}=    Create Entity Selecting Content Type
    ...    ${building_filename}
    ...    ${id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Query Entity    ${id}    context=${ngsild_test_suite_context}    accept=*/*
    Check Response Status Code    200    ${response.status_code}
    Check Response Headers Containing Content-Type set to    ${response.headers}    ${content_type}
    Check Response Headers Link Not Empty    ${response.headers}
    [Teardown]    Delete Entity by Id Returning Response    ${id}

044_02_02_endpoint /subscriptions/{subscriptionId}
    [Documentation]    Verify that on a GET HTTP request if nothing is specified on the Accept header, "application/json" is assumed (/subscriptions/{subscriptionId})
    [Tags]    sub-retrieve    6_3_4
    ${id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${response}=    Create Subscription    ${id}    ${subscription_filename}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Retrieve Subscription    ${id}    accept=*/*
    Check Response Status Code    200    ${response.status_code}
    Check Response Headers Containing Content-Type set to    ${response.headers}    ${content_type}
    Check Response Headers Link Not Empty    ${response.headers}
    [Teardown]    Delete Subscription    ${id}

044_02_03_endpoint /csourceRegistrations/
    [Documentation]    Verify that on a GET HTTP request if nothing is specified on the Accept header, "application/json" is assumed (/csourceRegistrations/)
    [Tags]    csr-query    6_3_4
    ${registration_id}=    Generate Random Entity Id    ${registration_id_prefix}
    ${payload}=    Load JSON From File    ${EXECDIR}/data/${registration_filename}
    ${updated_payload}=    Update Value To JSON    ${payload}    $..id    ${registration_id}
    ${response}=    Create Context Source Registration With Return    ${updated_payload}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Query Context Source Registrations With Return
    ...    id=${registration_id}
    ...    type=${registration_type}
    ...    context=${ngsild_test_suite_context}
    ...    accept=*/*
    Check Response Status Code    200    ${response.status_code}
    Check Response Headers Containing Content-Type set to    ${response.headers}    ${content_type}
    Check Response Headers Link Not Empty    ${response.headers}
    [Teardown]    Delete Context Source Registration    ${registration_id}

044_02_04_endpoint /temporal/entities
    [Documentation]    Verify that on a GET HTTP request if nothing is specified on the Accept header, "application/json" is assumed (/temporal/entities)
    [Tags]    te-query    6_3_4
    ${temporal_entity_representation_id}=    Generate Random Entity Id    ${tea_id_prefix}
    ${response}=    Create Or Update Temporal Representation Of Entity Selecting Content Type
    ...    ${temporal_entity_representation_id}
    ...    ${tea_filename}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Query Temporal Representation Of Entities With Return
    ...    entity_types=${teatype}
    ...    timerel=after
    ...    timeAt=2020-08-01T12:05:00Z
    ...    context=${ngsild_test_suite_context}
    ...    accept=*/*
    Check Response Status Code    200    ${response.status_code}
    Set Test Variable    ${response}
    Check Response Headers Containing Content-Type set to    ${response.headers}    ${content_type}
    Check Response Headers Link Not Empty    ${response.headers}
    [Teardown]    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
