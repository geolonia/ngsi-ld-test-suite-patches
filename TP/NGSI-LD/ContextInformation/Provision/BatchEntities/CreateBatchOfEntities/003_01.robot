*** Settings ***
Documentation   Check that you can create a batch of entities
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Batch Create Entity Scenarios

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:

*** Test Cases ***                        FILENAME
MinimalEntity                             building-minimal-sample.jsonld
EntityWithSimpleProperties                building-simple-attributes-sample.jsonld
EntityWithSimpleRelationships             building-relationship-sample.jsonld
EntityWithRelationshipsProperties         building-relationship-of-property-sample.jsonld

*** Keywords ***
Batch Create Entity Scenarios
    [Arguments]  ${filename}
    [Documentation]  Check that you can create a batch of entities
    [Tags]  mandatory   entityOperations

    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${second_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${first_entity}=    Load Entity    ${filename}      ${first_entity_id}
    ${second_entity}=    Load Entity    ${filename}      ${second_entity_id}
    @{entities_to_be_created}=  Create List   ${first_entity}     ${second_entity}

    Batch Create Entities   @{entities_to_be_created}

    @{expected_entities_ids}=  Create List   ${first_entity_id}     ${second_entity_id}
    Check Response Status Code Set To  201
    Check Response Body Containing Array Of URIs set to   @{expected_entities_ids}

    Batch Delete Entities       @{expected_entities_ids}
