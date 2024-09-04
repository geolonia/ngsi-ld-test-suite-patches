*** Settings ***
Documentation       Check that one can create a context source registration with specific ID and expiration date

Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceDiscovery.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistration.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Teardown      Delete Created Context Source Registrations
Test Template       Create Context Source Registration


*** Variables ***
${registration_id_prefix}=              urn:ngsi-ld:Registration:
${registration_payload_file_path}=      csourceRegistrations/context-source-registration-with-expiration.jsonld


*** Test Cases ***
033_01_01 Create Context Source Registration With Specific Date Expiration Date
    [Tags]    csr-create    5_9_2    since_v1.6.1
    csourceRegistrations/context-source-registration-with-expiration.jsonld
033_01_02 Create Context Source Registration That Never Expires
    [Tags]    csr-create    5_9_2    since_v1.6.1
    csourceRegistrations/context-source-registration.jsonld
033_01_03 Create Context Source Registration With Non Default Mode And Operations
    [Tags]    csr-create    5_9_2    since_v1.6.1
    csourceRegistrations/context-source-registration-with-mode-and-operations.jsonld
033_01_04 Create Context Source Registration With Location
    [Tags]    csr-create    5_9_2    since_v1.6.1
    csourceRegistrations/context-source-registration-location.jsonld


*** Keywords ***
Create Context Source Registration
    [Documentation]    Check that one can create a context source registration with specific ID and expiration date
    [Arguments]    ${registration_payload_file_path}
    ${registration_id}=    Generate Random Entity Id    ${registration_id_prefix}
    Set Suite Variable    ${registration_id}
    ${payload}=    Load JSON From File    ${EXECDIR}/data/${registration_payload_file_path}
    ${registration_payload}=    Update Value To JSON    ${payload}    $..id    ${registration_id}
    ${response}=    Create Context Source Registration With Return    ${registration_payload}
    Check Response Status Code    201    ${response.status_code}
    Check Response Headers Containing URI set to    ${registration_id}    ${response.headers}
    ${response1}=    Retrieve Context Source Registration
    ...    context_source_registration_id=${registration_id}
    ...    context=${ngsild_test_suite_context}
    ...    accept=${CONTENT_TYPE_LD_JSON}
    ${ignored_attributes}=    Create List    ${status_regex_expr}
    Check Created Resource Set To    ${registration_payload}    ${response1.json()}    ${ignored_attributes}

Delete Created Context Source Registrations
    Delete Context Source Registration    ${registration_id}
