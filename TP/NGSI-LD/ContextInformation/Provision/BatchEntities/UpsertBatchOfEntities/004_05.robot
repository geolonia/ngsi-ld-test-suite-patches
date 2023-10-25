*** Settings ***
Documentation       Check that you can upsert a batch of entities where some will succeed and others will fail

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision/ApiUtils.resource
# Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:


*** Test Cases ***
004_05_01 Upsert a batch of two valid entities and one invalid entity
    [Documentation]    Check that you can upsert a batch of two valid entities and one invalid entity
    [Tags]    be-upsert    5_6_8
    ${first_entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    ${second_entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    ${third_entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    ${first_entity}=    Load Entity    building-minimal-sample.jsonld    ${first_entity_id}
    ${second_entity}=    Load Entity    building-minimal-sample.jsonld    ${second_entity_id}
    ${third_entity}=    Load Entity    building-minimal-sample.jsonld    ${third_entity_id}
    ${invalid_entity}=    Remove Entity Type    ${third_entity}
    @{entities_to_be_upserted}=    Create List    ${first_entity}    ${second_entity}    ${invalid_entity}
    ${response}=    Batch Upsert Entities    @{entities_to_be_upserted}
    @{expected_successful_entities_ids}=    Create List    ${first_entity_id}    ${second_entity_id}
    @{expected_failed_entities_ids}=    Create List    ${third_entity_id}
    &{expected_batch_operation_result}=    Create Batch Operation Result
    ...    ${expected_successful_entities_ids}
    ...    ${expected_failed_entities_ids}
    Check Response Status Code    207    ${response.status_code}
    Check Response Body Containing Batch Operation Result    ${expected_batch_operation_result}    ${response.json()}
    ${expected_updated_entities_ids}=    Catenate    SEPARATOR=,    @{expected_successful_entities_ids}
    ${response}=    Query Entities
    ...    entity_ids=${expected_updated_entities_ids}
    ...    entity_types=Building
    ...    context=${ngsild_test_suite_context}
    ...    accept=${CONTENT_TYPE_LD_JSON}
    @{upserted_entities}=    Create List    ${first_entity}    ${second_entity}
    Check Updated Resources Set To    ${upserted_entities}    ${response.json()}
    ${response}=    Batch Delete Entities    entities_ids_to_be_deleted=@{expected_successful_entities_ids}
