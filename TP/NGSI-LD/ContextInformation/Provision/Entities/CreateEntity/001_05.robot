*** Settings ***
Documentation       Check that the default @context is used if the Content-Type header is "application/json" and the Link header does not contain a JSON-LD @context

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Teardown      Delete Initial Entity


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:
${filename}=                building-simple-attributes-sample.json


*** Test Cases ***
001_05_01 Create one entity using the default context with JSON content type and request without context
    [Documentation]    Check that the default @context is used if the Content-Type header is "application/json" and the Link header does not contain a JSON-LD @context
    [Tags]    e-create    6_3_5
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Suite Variable    ${entity_id}
    ${response}=    Create Entity Selecting Content Type    ${filename}    ${entity_id}    ${CONTENT_TYPE_JSON}
    ${response}=    Retrieve Entity by Id    id=${entity_id}
    # Attribute should be compacted as we used the same default context as provided when creating the entity
    Check Response Body Containing an Attribute set to    almostFull    ${response.json()}

001_05_02 Create one entity using the default context with JSON content type and request with context
    [Documentation]    Check that the default @context is used if the Content-Type header is "application/json" and the Link header does not contain a JSON-LD @context
    [Tags]    e-create    6_3_5
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Suite Variable    ${entity_id}
    ${response}=    Create Entity Selecting Content Type    ${filename}    ${entity_id}    ${CONTENT_TYPE_JSON}
    ${response}=    Retrieve Entity by Id
    ...    id=${entity_id}
    ...    accept=${CONTENT_TYPE_JSON}
    ...    context=${ngsild_test_suite_context}
    # Attribute should not be compacted as we did not provide a context containing this term
    Check Response Body Containing an Attribute set to    ngsi-ld:default-context/almostFull    ${response.json()}


*** Keywords ***
Delete Initial Entity
    Delete Entity by Id    ${entity_id}
