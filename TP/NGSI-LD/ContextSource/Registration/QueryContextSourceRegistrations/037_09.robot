*** Settings ***
Documentation  Check that you can query context source registrations. If present, the temporal query is matched against the observationInterval or the managementInterval
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Query Context Source Registration Matching Temporal Query

*** Variable ***
${context_source_registration_id_prefix}=  urn:ngsi-ld:ContextSourceRegistration:
${context_source_registration_observation_interval_payload_file_path}=   csourceRegistrations/context-source-registration-observationInterval-sample.jsonld
${context_source_registration_management_interval_payload_file_path}=   csourceRegistrations/context-source-registration-managementInterval-sample.jsonld
${observation_interval_expectation_file_path}=   csourceRegistrations/expectations/context-source-registrations-037-09-01-expectation.json
${management_interval_expectation_file_path}=   csourceRegistrations/expectations/context-source-registrations-037-09-02-expectation.json

*** Test Cases ***                          PAYLOAD_FILE_PATH                                                         TIMEPROPERTY        EXPECTATION_FILE_PATH
Observation Interval With observedAt        ${context_source_registration_observation_interval_payload_file_path}     observedAt          ${observation_interval_expectation_file_path}
Observation Interval Without timeproperty   ${context_source_registration_observation_interval_payload_file_path}     ${EMPTY}            ${observation_interval_expectation_file_path}
Mqnagement Interval With createdAt          ${context_source_registration_management_interval_payload_file_path}      createdAt           ${management_interval_expectation_file_path}
Mqnagement Interval With modifiedAt         ${context_source_registration_management_interval_payload_file_path}      modifiedAt          ${management_interval_expectation_file_path}

*** Keywords ***
Query Context Source Registration Matching Temporal Query
    [Arguments]  ${payload_file_path}   ${timeproperty}    ${expectation_file_path}
    [Documentation]  Check that you can query context source registrations. If present, the temporal query is matched against the observationInterval or the managementInterval
    [Tags]  mandatory

    ${context_source_registration_id}=     Generate Random Entity Id    ${context_source_registration_id_prefix}
    ${context_source_registration_payload}=  Load Test Sample    ${payload_file_path}    ${context_source_registration_id}
    Create Context Source Registration  ${context_source_registration_payload}
    Set Suite Variable  ${context_source_registration_id}

    Query Context Source Registrations      context=${ngsild_test_suite_context}    type=Building   timeproperty=${timeproperty}    timerel=before  timeAt=2021-08-01T22:00:00Z

    @{expected_context_source_registration_ids}=  Create List   ${context_source_registration_id}
    Check Response Status Code Set To  200
    Check Response Body Containing List Containing Context Source Registrations elements     ${expectation_file_path}   ${expected_context_source_registration_ids}

    [Teardown]  Delete Context Source Registration     ${context_source_registration_id}
