*** Settings ***
Documentation       Check that you can delete a batch of entities where some will succeed and others will fail

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Setup Initial Entities


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:


*** Test Cases ***
006_02_01 Delete a batch of non-existing and existing entities
    [Documentation]    Check that you can delete a batch of non-existing and existing entities
    [Tags]    be-delete    5_6_10
    ${new_entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    @{entities_ids_to_be_deleted}=    Create List    ${existing_entity_id}    ${new_entity_id}
    ${response}=    Batch Delete Entities    entities_ids_to_be_deleted=@{entities_ids_to_be_deleted}
    @{expected_successful_entities_ids}=    Create List    ${existing_entity_id}
    @{expected_failed_entities_ids}=    Create List    ${new_entity_id}
    &{expected_batch_operation_result}=    Create Batch Operation Result
    ...    ${expected_successful_entities_ids}
    ...    ${expected_failed_entities_ids}
    Check Response Status Code    207    ${response.status_code}
    Check Response Body Containing Batch Operation Result    ${expected_batch_operation_result}    ${response.json()}
    ${expected_entities_ids}=    Catenate    SEPARATOR=,    @{expected_successful_entities_ids}
    ${response}=    Query Entities
    ...    entity_ids=${expected_entities_ids}
    ...    entity_types=Building
    ...    context=${ngsild_test_suite_context}
    Check SUT Not Containing Resources    ${response.json()}


*** Keywords ***
Setup Initial Entities
    ${existing_entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Create Entity    building-simple-attributes-sample.jsonld    ${existing_entity_id}
    Set Suite Variable    ${existing_entity_id}
