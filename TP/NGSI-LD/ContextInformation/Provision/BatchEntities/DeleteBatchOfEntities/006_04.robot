*** Settings ***
Documentation       Check that one can delete a batch of entities with the same id

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Setup Initial Entity


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:


*** Test Cases ***
006_04_01 Delete a batch of existing entities with the same id
    [Documentation]    Check that one can delete a batch entities with the same id
    [Tags]    be-delete    5_6_10    since_v1.5.1
    ${new_entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    @{entities_ids_to_be_deleted}=    Create List    ${entity_id}    ${entity_id}

    ${response}=    Batch Delete Entities    entities_ids_to_be_deleted=@{entities_ids_to_be_deleted}

    @{expected_successful_entities_ids}=    Create List    ${entity_id}
    @{expected_failed_entities_ids}=    Create List    ${entity_id}
    &{response1}=    Create Batch Operation Result
    ...    ${expected_successful_entities_ids}
    ...    ${expected_failed_entities_ids}
    Check Response Status Code    207    ${response.status_code}
    Check Response Body Containing Batch Operation Result    ${response1}    ${response.json()}


*** Keywords ***
Setup Initial Entity
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Create Entity    building-simple-attributes-sample.jsonld    ${entity_id}
    Set Test Variable    ${entity_id}
