*** Settings ***
Documentation   Check that you can upsert a batch of non-existing entities and they will be created
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Batch Upsert Entity Scenarios

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:

*** Test Cases ***                        FILENAME
EntityWithSimpleProperties                building-simple-attributes-sample.jsonld
EntityWithSimpleRelationships             building-relationship-sample.jsonld
EntityWithRelationshipsProperties         building-relationship-of-property-sample.jsonld

*** Keywords ***
Batch Upsert Entity Scenarios
    [Arguments]  ${filename}
    [Documentation]  Check that you can upsert a batch of non existing entities
    [Tags]  mandatory

    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${second_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${first_entity}=    Load Entity    ${filename}      ${first_entity_id}
    ${second_entity}=    Load Entity    ${filename}      ${second_entity_id}
    @{entities_to_be_upserted}=  Create List   ${first_entity}     ${second_entity}

    Batch Upsert Entities   @{entities_to_be_upserted}

    @{expected_entities_ids}=  Create List   ${first_entity_id}     ${second_entity_id}
    Check Response Status Code Set To  201
    Check Response Body Containing Array Of URIs set to   @{expected_entities_ids}
    ${expected_updated_entities_ids}=  Catenate    SEPARATOR=,     @{expected_entities_ids}
    Query Entities    ${expected_updated_entities_ids}  Building    context=${ngsild_test_suite_context}    accept=${CONTENT_TYPE_LD_JSON}
    Check Updated Resources Set To   ${entities_to_be_upserted}

    Batch Delete Entities       @{expected_entities_ids}
