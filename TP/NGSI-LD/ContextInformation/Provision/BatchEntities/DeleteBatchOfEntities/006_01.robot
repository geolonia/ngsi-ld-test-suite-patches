*** Settings ***
Documentation       Check that you can delete a batch of entities

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Setup Initial Entities


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:


*** Test Cases ***
006_01_01 Delete a batch of entities
    [Documentation]    Check that you can delete a batch of entities
    [Tags]    be-delete    5_6_10
    @{entities_ids_to_be_deleted}=    Create List    ${first_entity_id}    ${second_entity_id}
    ${response}=    Batch Delete Entities    entities_ids_to_be_deleted=@{entities_ids_to_be_deleted}
    Check Response Status Code    204    ${response.status_code}
    ${expected_entities_ids}=    Catenate    SEPARATOR=,    @{entities_ids_to_be_deleted}
    ${response}=    Query Entities
    ...    entity_ids=${expected_entities_ids}
    ...    entity_types=Building
    ...    context=${ngsild_test_suite_context}
    Check SUT Not Containing Resources    ${response.json()}


*** Keywords ***
Setup Initial Entities
    ${first_entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    ${second_entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Create Entity    building-simple-attributes-sample.jsonld    ${first_entity_id}
    Create Entity    building-simple-attributes-sample.jsonld    ${second_entity_id}
    Set Suite Variable    ${first_entity_id}
    Set Suite Variable    ${second_entity_id}
