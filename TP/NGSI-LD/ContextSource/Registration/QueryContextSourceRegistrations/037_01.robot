*** Settings ***
Documentation     Check that you can query context source registrations if at least one of list of Entity Types or list of Attribute names is present
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Test Template     Query Context Source Registration
Suite Setup       Setup Initial Context Source Registrations
Suite Teardown    Delete Created Context Source Registrations

*** Variable ***
${context_source_registration_id_prefix}=    urn:ngsi-ld:ContextSourceRegistration:
${first_context_source_registration_payload_file_path}=    csourceRegistrations/context-source-registration-sample.jsonld
${second_context_source_registration_payload_file_path}=    csourceRegistrations/context-source-registration-detailed-information-sample.jsonld

*** Test Cases ***    QUERY_PARAM_NAME    QUERY_PARAM_VALUE    EXPECTATION_FILE_PATH                                                                     EXPECTED_CONTEXT_SOURCE_REGISTRATION_IDS
With list of entity types
                      type                Building             csourceRegistrations/expectations/context-source-registrations-037-01-expectation.json    ${first_context_source_registration_id}     ${second_context_source_registration_id}
                      [Tags]              csr-query            5_10_2

With list of attribute names
                      attrs               name                 csourceRegistrations/expectations/context-source-registrations-037-01-expectation.json    ${second_context_source_registration_id}
                      [Tags]              csr-query            5_10_2

*** Keywords ***
Query Context Source Registration
    [Arguments]    ${query_param_name}    ${query_param_value}    ${expectation_file_path}    @{expected_context_source_registration_ids}
    [Documentation]    Check that you can query context source registrations if at least one of list of Entity Types or list of Attribute names is present
    Query Context Source Registrations    context=${ngsild_test_suite_context}    ${query_param_name}=${query_param_value}
    Check Response Status Code Set To    200
    Check Response Body Containing List Containing Context Source Registrations elements    ${expectation_file_path}    ${expected_context_source_registration_ids}

Setup Initial Context Source Registrations
    ${first_context_source_registration_id}=    Generate Random Entity Id    ${context_source_registration_id_prefix}
    ${second_context_source_registration_id}=    Generate Random Entity Id    ${context_source_registration_id_prefix}
    ${first_context_source_registration_payload}=    Load Test Sample    ${first_context_source_registration_payload_file_path}    ${first_context_source_registration_id}
    ${second_context_source_registration_payload}=    Load Test Sample    ${second_context_source_registration_payload_file_path}    ${second_context_source_registration_id}
    Create Context Source Registration    ${first_context_source_registration_payload}
    Create Context Source Registration    ${second_context_source_registration_payload}
    Set Suite Variable    ${first_context_source_registration_id}
    Set Suite Variable    ${second_context_source_registration_id}

Delete Created Context Source Registrations
    Delete Context Source Registration    ${first_context_source_registration_id}
    Delete Context Source Registration    ${second_context_source_registration_id}
