*** Settings ***
Documentation       Check that one can create a batch of entities where two have the same id

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Teardown       Delete Entities


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:


*** Test Cases ***
003_10_01 Create a batch of three valid entities where two have the same id
    [Documentation]    Check that one can create a batch of entities where two have the same id
    [Tags]    be-create    5_6_7    since_v1.5.1
    ${first_entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Suite Variable    ${first_entity_id}
    ${second_entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Suite Variable    ${second_entity_id}
    ${first_entity}=    Load Entity    building-minimal-sample.jsonld    ${first_entity_id}
    ${second_entity}=    Load Entity    building-minimal-sample.jsonld    ${second_entity_id}
    @{entities_to_be_created}=    Create List    ${first_entity}    ${second_entity}    ${first_entity}

    ${response}=    Batch Create Entities    @{entities_to_be_created}

    Check Response Status Code    207    ${response.status_code}
    @{expected_successful_entities_ids}=    Create List    ${first_entity_id}    ${second_entity_id}
    Set Test Variable    @{expected_successful_entities_ids}
    @{expected_failed_entities_ids}=    Create List    ${first_entity_id}
    &{expected_batch_operation_result}=    Create Batch Operation Result
    ...    ${expected_successful_entities_ids}
    ...    ${expected_failed_entities_ids}
    Check Response Body Containing Batch Operation Result    ${expected_batch_operation_result}    ${response.json()}


*** Keywords ***
Delete Entities
    ${response}=    Batch Delete Entities
    ...    entities_ids_to_be_deleted=@{expected_successful_entities_ids}
