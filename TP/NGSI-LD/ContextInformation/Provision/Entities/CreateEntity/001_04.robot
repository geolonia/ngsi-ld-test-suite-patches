*** Settings ***
Documentation       Check that the @context is obtained from a Link Header if the Content-Type header is "application/json"

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Create Initial Entity
Test Teardown       Delete Initial Entity


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:
${filename}=                building-simple-attributes-sample.json


*** Test Cases ***
001_04_01 Create one entity using a provided Link header with JSON content type and NGSILD context
    [Documentation]    Check that the @context is obtained from a Link Header if the Content-Type header is "application/json"
    [Tags]    e-create    6_3_5
    ${response}=    Retrieve Entity by Id    id=${entity_id}    context=${ngsild_test_suite_context}
    # Attribute should be compacted as we used the same context as provided when creating the entity
    Check Response Body Containing an Attribute set to
    ...    expected_attribute_name=almostFull
    ...    response_body=${response.json()}

001_04_02 Create one entity using a provided Link header with JSON content type and no context
    [Documentation]    Check that the @context is obtained from a Link Header if the Content-Type header is "application/json"
    [Tags]    e-create    6_3_5
    ${response}=    Retrieve Entity by Id    id=${entity_id}
    # Attribute should not be compacted as we did not provide a context containing this term
    Check Response Body Containing an Attribute set to
    ...    expected_attribute_name=https://ngsi-ld-test-suite/context#almostFull
    ...    response_body=${response.json()}


*** Keywords ***
Create Initial Entity
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Suite Variable    ${entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_JSON}
    ...    context=${ngsild_test_suite_context}

Delete Initial Entity
    Delete Entity by Id    ${entity_id}
