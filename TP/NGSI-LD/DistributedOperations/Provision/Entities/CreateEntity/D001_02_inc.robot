*** Settings ***
Documentation       Check that if one requests the Context Broker to create an entity that matches an inclusive registration but is malformed, this is created neither on the Context Broker nor on the Context Source

Resource            ${EXECDIR}/resources/ApiUtils/Common.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceDiscovery.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistration.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Setup Initial Context Source Registration
Test Teardown       Delete Created Registration


*** Variables ***
${entity_id}                                        InvalidUriExample
${entity_payload_filename}                          vehicle-simple-attributes.jsonld
${context_source_registration_payload_file_path}    csourceRegistrations/context-source-registration-vehicle-redirection-ops.jsonld


*** Test Cases ***
D001_02_inc Request to create an entity with a malformed id on both Context Broker and Context Source
    [Documentation]    Check that if one requests the Context Broker to create an entity that matches an inclusive registration but is malformed, this is created neither on the Context Broker nor on the Context Source
    [Tags]    since_v1.6.1    dist-ops    4_3_3    cf_06    additive-inclusive    4_3_6_2    5_6_1    6_3_3
    ${response}=    Create Entity    ${entity_payload_filename}    ${entity_id}
    Check Response Status Code    400    ${response.status_code}

    ${response_query}=    Query Entities    entity_types=Vehicle    local=true    context=${ngsild_test_suite_context}
    Check Response Status Code    200    ${response_query.status_code}
    Should Be Empty    ${response_query.json()}
    ${response_query_remote}=    Query Entities    entity_types=Vehicle    base_url=${remote_url}
    Check Response Status Code    200    ${response_query_remote.status_code}
    Should Be Empty    ${response_query_remote.json()}


*** Keywords ***
Setup Initial Context Source Registration
    ${context_source_registration_id}=    Generate Random CSR Id
    Set Suite Variable    ${context_source_registration_id}
    ${registration_payload}=    Prepare Context Source Registration From File
    ...    ${context_source_registration_id}
    ...    ${context_source_registration_payload_file_path}
    ${response1}=    Create Context Source Registration With Return    ${registration_payload}
    Check Response Status Code    201    ${response1.status_code}

Delete Created Registration
    Delete Context Source Registration    ${context_source_registration_id}
