*** Settings ***
Documentation       Check that you can query context source registrations with providing page and limit parameters, pagination logic shall be in place as mandated by clause 5.5.9.

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Setup Initial Context Source Registrations
Test Teardown       Delete Created Context Source Registrations
Test Template       Query Context Source Registration With Limit And Page Parameters


*** Variables ***
${context_source_registration_id_prefix}=                   urn:ngsi-ld:ContextSourceRegistration:
${first_context_source_registration_payload_file_path}=     csourceRegistrations/context-source-registration-sample.jsonld
${second_context_source_registration_payload_file_path}=    csourceRegistrations/context-source-registration-location-sample.jsonld
${third_context_source_registration_payload_file_path}=     csourceRegistrations/context-source-registration-detailed-information-sample.jsonld


*** Test Cases ***    LIMIT    PAGE    EXPECTED_NUMBER    PREV_LINK    NEXT_LINK
Query Second Subscription
    [Tags]    csr-query    5_10_2
    ${1}    ${2}    ${1}    </ngsi-ld/v1/csourceRegistrations?type=Building&limit=1&page=1>;rel="prev";type="application/ld+json"    </ngsi-ld/v1/csourceSubscriptions?type=Building&limit=1&page=3>;rel="next";type="application/ld+json"
Query Last Subscription
    [Tags]    csr-query    5_10_2
    ${2}    ${2}    ${1}    </ngsi-ld/v1/csourceRegistrations?type=Building&limit=2&page=1>;rel="prev";type="application/ld+json"    ${EMPTY}
Query All Subscriptions
    [Tags]    csr-query    5_10_2
    ${15}    ${1}    ${3}    ${EMPTY}    ${EMPTY}


*** Keywords ***
Query Context Source Registration With Limit And Page Parameters
    [Documentation]    Check that you can query context source registrations with providing page and limit parameters, pagination logic shall be in place as mandated by clause 5.5.9.
    [Arguments]    ${limit}    ${page}    ${expected_number}    ${prev_link}    ${next_link}
    ${response}=    Query Context Source Registrations
    ...    context=${ngsild_test_suite_context}
    ...    type=Building
    ...    limit=${limit}
    ...    page=${page}
    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing Number Of Entities
    ...    ContextSourceRegistration
    ...    ${expected_number}
    ...    ${response.json()}
    Check Pagination Prev And Next Headers    ${prev_link}    ${next_link}    ${response.json()}

Setup Initial Context Source Registrations
    ${first_context_source_registration_id}=    Generate Random Entity Id    ${context_source_registration_id_prefix}
    ${second_context_source_registration_id}=    Generate Random Entity Id    ${context_source_registration_id_prefix}
    ${third_context_source_registration_id}=    Generate Random Entity Id    ${context_source_registration_id_prefix}
    ${first_context_source_registration_payload}=    Load Test Sample
    ...    ${first_context_source_registration_payload_file_path}
    ...    ${first_context_source_registration_id}
    ${second_context_source_registration_payload}=    Load Test Sample
    ...    ${second_context_source_registration_payload_file_path}
    ...    ${second_context_source_registration_id}
    ${third_context_source_registration_payload}=    Load Test Sample
    ...    ${third_context_source_registration_payload_file_path}
    ...    ${third_context_source_registration_id}
    Create Context Source Registration    ${first_context_source_registration_payload}
    Create Context Source Registration    ${second_context_source_registration_payload}
    Create Context Source Registration    ${third_context_source_registration_payload}
    Set Test Variable    ${first_context_source_registration_id}
    Set Test Variable    ${second_context_source_registration_id}
    Set Test Variable    ${third_context_source_registration_id}

Delete Created Context Source Registrations
    Delete Context Source Registration    ${first_context_source_registration_id}
    Delete Context Source Registration    ${second_context_source_registration_id}
    Delete Context Source Registration    ${third_context_source_registration_id}
