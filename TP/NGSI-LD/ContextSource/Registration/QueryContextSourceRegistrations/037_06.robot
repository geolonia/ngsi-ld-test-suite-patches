*** Settings ***
Documentation   Check that you can query context source registrations matching property and relationships names of RegistrationInfo
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Query Context Source Registration Matching Properties And Relationships Of RegistrationInfo
Suite Setup      Setup Initial Context Source Registration
Suite Teardown      Delete Created Context Source Registration

*** Variable ***
${context_source_registration_id_prefix}=  urn:ngsi-ld:ContextSourceRegistration:
${context_source_registration_payload_file_path}=   csourceRegistrations/context-source-registration-detailed-information-sample.jsonld

*** Test Cases ***                                  ATTRS_VALUE           EXPECTATION_FILE_PATH
Query With Matching Properties And Relationships    name,locatedAt        csourceRegistrations/expectations/context-source-registrations-037-06-expectation.json
Query Without Properties And Relationships          ${EMPTY}              csourceRegistrations/expectations/context-source-registrations-037-06-expectation.json

*** Keywords ***
Query Context Source Registration Matching Properties And Relationships Of RegistrationInfo
    [Arguments]  ${attrs_value}     ${expectation_file_path}
    [Documentation]  Check that you can query context source registrations matching property and relationships names of RegistrationInfo
    [Tags]  mandatory

    Query Context Source Registrations      context=${ngsild_test_suite_context}    type=Building   attrs=${attrs_value}

    @{expected_context_source_registration_ids}=  Create List   ${context_source_registration_id}
    Check Response Status Code Set To  200
    Check Response Body Containing List Containing Context Source Registrations elements     ${expectation_file_path}   ${expected_context_source_registration_ids}

*** Keywords ***
Setup Initial Context Source Registration
    ${context_source_registration_id}=     Generate Random Entity Id    ${context_source_registration_id_prefix}
    ${context_source_registration_payload}=  Load Test Sample    ${context_source_registration_payload_file_path}    ${context_source_registration_id}

    Create Context Source Registration  ${context_source_registration_payload}

    Set Suite Variable  ${context_source_registration_id}

Delete Created Context Source Registration
    Delete Context Source Registration     ${context_source_registration_id}
