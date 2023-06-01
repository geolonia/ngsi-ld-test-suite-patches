*** Settings ***
Documentation       Check that the @context is obtained from a Link Header if the Content-Type header is "application/json"

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:


*** Test Cases ***
Create a batch of one entity using a provided Link header with JSON content type
    [Documentation]    Check that the @context is obtained from a Link Header if the Content-Type header is "application/json"
    [Tags]    be-create    6_3_5
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    ${entity}=    Load Entity    building-simple-attributes-sample.json    ${entity_id}
    @{entities_to_be_created}=    Create List    ${entity}
    ${response}=    Batch Create Entities
    ...    @{entities_to_be_created}
    ...    content_type=${CONTENT_TYPE_JSON}
    ...    context=${ngsild_test_suite_context}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Retrieve Entity by Id    ${entity_id}    context=${ngsild_test_suite_context}
    # Attribute should be compacted as we used the same context as provided when creating the entity
    Check Response Body Containing an Attribute set to    almostFull    ${response.json()}
    ${response}=    Retrieve Entity by Id    ${entity_id}
    # Attribute should not be compacted as we did not provide a context containing this attribute
    Check Response Body Containing an Attribute set to
    ...    https://ngsi-ld-test-suite/context#almostFull
    ...    ${response.json()}
    @{entities_ids_to_be_deleted}=    Create List    ${entity_id}
    ${response}=    Batch Delete Entities    @{entities_ids_to_be_deleted}
