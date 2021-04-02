*** Settings ***
Documentation   Check that you can query the temporal evolution of entities matching the given NGSI-LD Context Source filter
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource
Resource    ${EXECDIR}/resources/MockServerUtils.resource

Suite Setup      Create Initial Context Source Registration
Suite Teardown      Delete Initial Context Source Registration

*** Variable ***
${context_source_registration_id_prefix}=  urn:ngsi-ld:ContextSourceRegistration:
${context_source_registration_payload_file_path}=   csourceRegistrations/context-source-registration-observationInterval-sample.jsonld
${context_source_url}=     http://${context_source_host}:${context_source_port}

*** Test Case ***
Query the temporal evolution of entities matching the given NGSI-LD context source filter
    [Documentation]  Check that you can query the temporal evolution of entities matching the given NGSI-LD Context Source filter
    [Tags]   te-query    5_7_4

    ${entity_types_to_be_retrieved}=  Catenate    SEPARATOR=,     Building

    Query Temporal Representation Of Entities   entity_types=${entity_types_to_be_retrieved}    csf=endpoint=="${context_source_url}"    timerel=after    timeAt=2020-07-01T12:05:00Z    context=${ngsild_test_suite_context}

    Wait for redirected request
    Check Response Status Code Set To  200

*** Keywords ***
Create Initial Context Source Registration
    Start Context Source Mock Server

    ${context_source_registration_id}=     Generate Random Entity Id    ${context_source_registration_id_prefix}
    ${context_source_registration_payload}=  Load Context Source Registration Sample With Reachable Context Source    ${context_source_registration_payload_file_path}    ${context_source_registration_id}

    Create Context Source Registration  ${context_source_registration_payload}

    Set Suite Variable  ${context_source_registration_id}

Delete Initial Context Source Registration
    Stop Context Source Mock Server

    Delete Context Source Registration     ${context_source_registration_id}
