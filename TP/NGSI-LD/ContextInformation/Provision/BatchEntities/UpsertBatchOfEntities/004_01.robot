*** Settings ***
Documentation   Check that you can upsert a batch of non-existing entities and they will be created
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:

*** Test Case ***
Upsert a batch of non existing entities
    [Documentation]  Check that you can upsert a batch of non existing entities
    [Tags]  mandatory

    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${second_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${first_entity}=    Load Entity    building-minimal-sample.jsonld      ${first_entity_id}
    ${second_entity}=    Load Entity    building-minimal-sample.jsonld      ${second_entity_id}
    @{entities_to_be_upserted}=  Create List   ${first_entity}     ${second_entity}

    Batch Upsert Entities   @{entities_to_be_upserted}

    @{expected_entities_ids}=  Create List   ${first_entity_id}     ${second_entity_id}
    Check Response Status Code Set To  201
    Check Response Body Containing Array Of URIs set to   @{expected_entities_ids}

    Batch Delete Entities       @{expected_entities_ids}
