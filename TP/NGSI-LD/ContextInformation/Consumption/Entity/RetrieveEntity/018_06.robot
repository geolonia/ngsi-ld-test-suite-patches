*** Settings ***
Documentation   Check that the JSON-LD @context is obtained from a Link header if present and that the default JSON-LD @context is used if not present
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Setup Initial Entity
Suite Teardown      Delete Created Entity

Test Template       Check Json-LD Resolution When retrieving an entity

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:
${filename}=  building-simple-attributes-sample.json
${empty_jsonld_expectation_filename}=  building-simple-attributes-sample-expanded-expectation.json
${creation_jsonld_expectation_filename}=  building-simple-attributes-sample-compacted-expectation.json

*** Test Cases ***                        CONTEXT                           EXPECTED_PAYLOAD
EmptyJsonLdContext                        ${EMPTY}                          ${empty_jsonld_expectation_filename}
    [Tags]   e-retrieve    6_3_5
CreationTimeJsonLdContext                 ${ngsild_test_suite_context}      ${creation_jsonld_expectation_filename}
    [Tags]   e-retrieve    6_3_5

*** Keywords ***
Check Json-LD Resolution When retrieving an entity
    [Arguments]  ${context}     ${expected_payload}
    [Documentation]  Check that the JSON-LD @context is obtained from a Link header if present and that the default JSON-LD @context is used if not present

    ${request}    ${response}=    Query Entity    ${entity_id}    ${CONTENT_TYPE_JSON}     context=${context}
    Check Response Status Code  200    ${response['status']}
    Check Response Body Containing Entity element    ${expected_payload}    ${entity_id}    ${response['body']}

Setup Initial Entity
    ${entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    Create Entity Selecting Content Type  ${filename}     ${entity_id}    ${CONTENT_TYPE_JSON}   context=${ngsild_test_suite_context}

    Set Suite Variable  ${entity_id}

Delete Created Entity
    Delete Entity by Id Returning Response   ${entity_id}