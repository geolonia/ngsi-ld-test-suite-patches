*** Settings ***
Documentation       Check that the JSON-LD @context is obtained from a Link header if present and that the default JSON-LD @context is used if not present

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Setup Initial Context Source Registration
Suite Teardown      Delete Created Context Source Registration
Test Template       Check JSON-LD resolution when retrieving a context source registration


*** Variables ***
${context_source_registration_id_prefix}=               urn:ngsi-ld:ContextSourceRegistration:
${context_source_registration_payload_file_path}=       csourceRegistrations/context-source-registration-sample.jsonld
${expectation_file_path_compacted}=                     csourceRegistrations/expectations/context-source-registration.json
${expectation_file_path_expanded}=                      csourceRegistrations/expectations/context-source-registration-expanded-format.json


*** Test Cases ***    CONTEXT    EXPECTED_PAYLOAD
EmptyJsonLdContext
    [Tags]    csr-retrieve    6_3_5
    ${EMPTY}    ${expectation_file_path_expanded}
CreationTimeJsonLdContext
    [Tags]    csr-retrieve    6_3_5
    ${ngsild_test_suite_context}    ${expectation_file_path_compacted}


*** Keywords ***
Check JSON-LD resolution when retrieving a context source registration
    [Documentation]    Check that the JSON-LD @context is obtained from a Link header if present and that the default JSON-LD @context is used if not present
    [Arguments]    ${context}    ${expected_payload}
    ${response}=    Retrieve Context Source Registration    ${context_source_registration_id}    context=${context}
    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing Context Source Registration element
    ...    ${expected_payload}
    ...    ${context_source_registration_id}

Setup Initial Context Source Registration
    ${context_source_registration_id}=    Generate Random Entity Id    ${context_source_registration_id_prefix}
    ${context_source_registration_payload}=    Load Test Sample
    ...    ${context_source_registration_payload_file_path}
    ...    ${context_source_registration_id}
    Create Context Source Registration    ${context_source_registration_payload}
    Set Suite Variable    ${context_source_registration_id}

Delete Created Context Source Registration
    Delete Context Source Registration    ${context_source_registration_id}
