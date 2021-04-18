*** Settings ***
Documentation     Check that you can query context source registrations matching EntityInfo of RegistrationInfo
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Test Template     Query Context Source Registration Matching EntityInfo of RegistrationInfo

*** Variable ***
${context_source_registration_id_prefix}=    urn:ngsi-ld:ContextSourceRegistration:

*** Test Cases ***    REGISTRATION_FILE_PATH                                                                             EXPECTATION_FILE_PATH
Registration With EntityInfo Matching The Query
                      csourceRegistrations/context-source-registration-sample.jsonld                                     csourceRegistrations/expectations/context-source-registrations-037-05-01-expectation.json
                      [Tags]                                                                                             csr-query                                                                                    5_10_2

Registration Without EntityInfo
                      csourceRegistrations/context-source-registration-with-only-properties-information-sample.jsonld    csourceRegistrations/expectations/context-source-registrations-037-05-02-expectation.json
                      [Tags]                                                                                             csr-query                                                                                    5_10_2

*** Keywords ***
Query Context Source Registration Matching EntityInfo of RegistrationInfo
    [Arguments]    ${registration_file_path}    ${expectation_file_path}
    [Documentation]    Check that you can query context source registrations matching EntityInfo of RegistrationInfo
    ${context_source_registration_id}=    Generate Random Entity Id    ${context_source_registration_id_prefix}
    ${context_source_registration_payload}=    Load Test Sample    ${registration_file_path}    ${context_source_registration_id}
    Create Context Source Registration    ${context_source_registration_payload}
    Set Suite Variable    ${context_source_registration_id}
    Query Context Source Registrations    context=${ngsild_test_suite_context}    type=Building    attrs=name
    @{expected_context_source_registration_ids}=    Create List    ${context_source_registration_id}
    Check Response Status Code Set To    200
    Check Response Body Containing List Containing Context Source Registrations elements    ${expectation_file_path}    ${expected_context_source_registration_ids}
    [Teardown]    Delete Context Source Registration    ${context_source_registration_id}
