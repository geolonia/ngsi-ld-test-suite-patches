*** Settings ***
Documentation     Check that you can query context source registrations. If a JSON-LD context is not provided, then all the query terms shall be resolved against the default JSON-LD @context
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Suite Setup       Setup Initial Context Source Registration
Suite Teardown    Delete Created Context Source Registration

*** Variable ***
${context_source_registration_id_prefix}=    urn:ngsi-ld:ContextSourceRegistration:
${context_source_registration_payload_file_path}=    csourceRegistrations/context-source-registration-sample.jsonld
${expectation_file_path}=    csourceRegistrations/expectations/context-source-registrations-037-04-expectation.json

*** Test Case ***
Query Context Source Registrations Without Context
    [Documentation]    Check that you can query context source registrations. If a JSON-LD context is not provided, then all the query terms shall be resolved against the default JSON-LD @context
    [Tags]    csr-query    5_10_2
    Query Context Source Registrations    id=${context_source_registration_id}
    @{expected_context_source_registration_ids}=    Create List    ${context_source_registration_id}
    Check Response Status Code Set To    200
    Check Response Body Containing List Containing Context Source Registrations elements    ${expectation_file_path}    ${expected_context_source_registration_ids}

*** Keywords ***
Setup Initial Context Source Registration
    ${context_source_registration_id}=    Generate Random Entity Id    ${context_source_registration_id_prefix}
    ${context_source_registration_payload}=    Load Test Sample    ${context_source_registration_payload_file_path}    ${context_source_registration_id}
    Create Context Source Registration    ${context_source_registration_payload}
    Set Suite Variable    ${context_source_registration_id}

Delete Created Context Source Registration
    Delete Context Source Registration    ${context_source_registration_id}
