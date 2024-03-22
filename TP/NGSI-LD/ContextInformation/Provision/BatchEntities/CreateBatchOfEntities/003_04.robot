*** Settings ***
Documentation       Check that the @context is obtained from a Link Header if the Content-Type header is "application/json"

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Teardown       Delete Initial Entities


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:


*** Test Cases ***
003_04_01 Create a batch of one entity using a provided Link header with JSON content type and retrieve the entity with context detail
    [Documentation]    Check that the @context is obtained from a Link Header if the Content-Type header is "application/json"
    [Tags]    be-create    6_3_5

    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Test Variable    ${entity_id}
    ${entity}=    Load Entity    building-simple-attributes-sample.json    ${entity_id}
    @{entities_to_be_created}=    Create List    ${entity}
    ${response}=    Batch Create Entities
    ...    @{entities_to_be_created}
    ...    content_type=${CONTENT_TYPE_JSON}
    ...    context=${ngsild_test_suite_context}
    Check Response Status Code    201    ${response.status_code}

    ${response1}=    Retrieve Entity by Id
    ...    id=${entity_id}
    ...    context=${ngsild_test_suite_context}
    # Attribute should be compacted as we used the same context as provided when creating the entity
    Check Response Body Containing an Attribute set to
    ...    expected_attribute_name=almostFull
    ...    response_body=${response1.json()}

003_04_02 Create a batch of one entity using a provided Link header with JSON content type and retrieve the entity without context detail
    [Documentation]    Check that the @context is obtained from a Link Header if the Content-Type header is "application/json"
    [Tags]    be-create    6_3_5

    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Test Variable    ${entity_id}
    ${entity}=    Load Entity    building-simple-attributes-sample.json    ${entity_id}
    @{entities_to_be_created}=    Create List    ${entity}
    ${response}=    Batch Create Entities
    ...    @{entities_to_be_created}
    ...    content_type=${CONTENT_TYPE_JSON}
    ...    context=${ngsild_test_suite_context}
    Check Response Status Code    201    ${response.status_code}

    ${response1}=    Retrieve Entity by Id
    ...    id=${entity_id}
    # Attribute should not be compacted as we did not provide a context containing this attribute
    Check Response Body Containing an Attribute set to
    ...    expected_attribute_name=https://ngsi-ld-test-suite/context#almostFull
    ...    response_body=${response1.json()}


*** Keywords ***
Delete Initial Entities
    @{entities_ids_to_be_deleted}=    Create List    ${entity_id}
    Batch Delete Entities    entities_ids_to_be_deleted=@{entities_ids_to_be_deleted}
