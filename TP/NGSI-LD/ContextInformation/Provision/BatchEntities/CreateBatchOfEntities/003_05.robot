*** Settings ***
Documentation       Check that the default @context is used if the Content-Type header is "application/json" and the Link header does not contain a JSON-LD @context

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Teardown      Delete Initial Entities


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:


*** Test Cases ***
003_05_01 Create a batch of one entity using the default context with JSON content type
    [Documentation]    Check that the default @context is used if the Content-Type header is "application/json" and the Link header does not contain a JSON-LD @context
    [Tags]    be-create    6_3_5
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Suite Variable    ${entity_id}
    ${entity}=    Load Entity    building-simple-attributes-sample.json    ${entity_id}
    @{entities_to_be_created}=    Create List    ${entity}
    ${response}=    Batch Create Entities    @{entities_to_be_created}    content_type=${CONTENT_TYPE_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Retrieve Entity by Id    ${entity_id}
    # Attribute should be compacted as we used the same default context as provided when creating the entity
    Check Response Body Containing an Attribute set to    almostFull    ${response.json()}
    ${response}=    Retrieve Entity by Id    ${entity_id}    context=${ngsild_test_suite_context}
    # Attribute should not be compacted as we did not provide a context containing this term
    Check Response Body Containing an Attribute set to    ngsi-ld:default-context/almostFull    ${response.json()}


*** Keywords ***
Delete Initial Entities
    @{entities_ids_to_be_deleted}=    Create List    ${entity_id}
    ${response}=    Batch Delete Entities    @{entities_ids_to_be_deleted}
