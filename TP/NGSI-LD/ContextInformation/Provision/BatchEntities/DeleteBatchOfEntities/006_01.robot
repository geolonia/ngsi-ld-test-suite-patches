*** Settings ***
Documentation   Check that you can delete a batch of entities
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Suite Setup      Setup Initial Entities

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:

*** Test Case ***
Delete a batch of entities
    [Documentation]  Check that you can delete a batch of entities
    [Tags]  mandatory

    @{entities_ids_to_be_deleted}=  Create List   ${first_entity_id}     ${second_entity_id}

    Batch Delete Entities   @{entities_ids_to_be_deleted}

    Check Response Status Code Set To  204

    ${expected_entities_ids}=  Catenate    SEPARATOR=,     @{entities_ids_to_be_deleted}

    Query Entities    ${expected_entities_ids}  Building    context=${ngsild_test_suite_context}
    Check SUT Not Containing Resources

*** Keywords ***
Setup Initial Entities
    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${second_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    Create Entity  building-simple-attributes-sample.jsonld     ${first_entity_id}
    Create Entity  building-simple-attributes-sample.jsonld     ${second_entity_id}

    Set Suite Variable  ${first_entity_id}
    Set Suite Variable  ${second_entity_id}
