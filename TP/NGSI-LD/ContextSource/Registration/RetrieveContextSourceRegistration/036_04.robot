*** Settings ***
Documentation     Check that you can retrieve a Context Source Registration
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Suite Setup       Setup Initial Context Source Registration
Suite Teardown    Delete Created Context Source Registration

*** Variable ***
${context_source_registration_id_prefix}=    urn:ngsi-ld:ContextSourceRegistration:
${context_source_registration_payload_file_path}=    csourceRegistrations/context-source-registration-sample.jsonld
${expectation_file_path}=    csourceRegistrations/expectations/context-source-registration.json

*** Test Case ***
Retrieve Context Source Registration
    [Documentation]    Check that you can retrieve a Context Source Registration
    [Tags]    csr-retrieve    5_10_1
    Retrieve Context Source Registration    ${context_source_registration_id}    context=${ngsild_test_suite_context}
    Check Response Status Code Set To    200
    Check Response Body Containing Context Source Registration element    ${expectation_file_path}    ${context_source_registration_id}

*** Keywords ***
Setup Initial Context Source Registration
    ${context_source_registration_id}=    Generate Random Entity Id    ${context_source_registration_id_prefix}
    ${context_source_registration_payload}=    Load Test Sample    ${context_source_registration_payload_file_path}    ${context_source_registration_id}
    Create Context Source Registration    ${context_source_registration_payload}
    Set Suite Variable    ${context_source_registration_id}

Delete Created Context Source Registration
    Delete Context Source Registration    ${context_source_registration_id}
