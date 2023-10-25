*** Settings ***
Documentation       Check that the @context is obtained from the request payload body itself if the Content-Type header is "application/ld+json"

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Teardown      Delete Initial Entities


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:


*** Test Cases ***
003_07_01 Create a batch of one entity using a JSON-LD @context obtained from the request payload
    [Documentation]    Check that the @context is obtained from the request payload body itself if the Content-Type header is "application/ld+json" and ther response attribute should be compacted as we used the same context as provided when creating the entity
    [Tags]    be-create    6_3_5
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Suite Variable    ${entity_id}
    ${entity}=    Load Entity    building-simple-attributes-sample.jsonld    ${entity_id}
    @{entities_to_be_created}=    Create List    ${entity}
    ${response}=    Batch Create Entities    @{entities_to_be_created}    content_type=${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Retrieve Entity by Id
    ...    id=${entity_id}
    ...    context=${ngsild_test_suite_context}
    # Attribute should be compacted as we used the same context as provided when creating the entity
    Check Response Body Containing an Attribute set to
    ...    expected_attribute_name=almostFull
    ...    response_body=${response.json()}

003_07_02 Create a batch of one entity using a JSON-LD @context obtained from the request payload
    [Documentation]    Check that the @context is obtained from the request payload body itself if the Content-Type header is "application/ld+json" and response attribute should not be compacted as we did not provide a context containing this term
    [Tags]    be-create    6_3_5
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Suite Variable    ${entity_id}
    ${entity}=    Load Entity    building-simple-attributes-sample.jsonld    ${entity_id}
    @{entities_to_be_created}=    Create List    ${entity}
    ${response}=    Batch Create Entities    @{entities_to_be_created}    content_type=${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Retrieve Entity by Id
    ...    id=${entity_id}
    # Attribute should not be compacted as we did not provide a context containing this term
    Check Response Body Containing an Attribute set to
    ...    expected_attribute_name=https://ngsi-ld-test-suite/context#almostFull
    ...    response_body=${response.json()}


*** Keywords ***
Delete Initial Entities
    @{entities_ids_to_be_deleted}=    Create List    ${entity_id}
    ${response}=    Batch Delete Entities
    ...    entities_ids_to_be_deleted=@{entities_ids_to_be_deleted}
