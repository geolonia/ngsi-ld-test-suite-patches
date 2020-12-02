*** Settings ***
Documentation   Check that you can create a batch of entities
Variables   ../../../../../../resources/variables.py
Resource    ../../../../../../resources/ApiUtils.resource
Resource    ../../../../../../resources/AssertionUtils.resource
Resource    ../../../../../../resources/JsonUtils.resource
Library     REST    ${url}
Library     JSONLibrary
Library     String
Library     Collections

*** Variable ***
${batch_endpoint}=    entityOperations/create
${endpoint}=    entities
${building_id_prefix}=  urn:ngsi-ld:Building:

*** Test Case ***
Create a batch of minimal entities
    [Documentation]  Check that you can create a batch of minimal entities
    [Tags]  critical

    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${second_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${first_entity}=    Load Entity    building-minimal-sample.jsonld      ${first_entity_id}
    ${second_entity}=    Load Entity    building-minimal-sample.jsonld      ${second_entity_id}
    @{entities_to_be_created}=  Create List   ${first_entity}     ${second_entity}

    Batch Create Entities   @{entities_to_be_created}

    @{expected_entities_ids}=  Create List   ${first_entity_id}     ${second_entity_id}
    Check Response Status Code Set To  201
    Check Response Body Containing Array Of URIs set to   @{expected_entities_ids}

    #TODO call Batch Delete Entities
    Delete Entity by Id  ${first_entity_id}
    Delete Entity by Id  ${second_entity_id}

Create a batch of entities having only simple properties
    [Documentation]  Check that you can create a batch of entities having only simple properties
    [Tags]  critical

    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${second_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${first_entity}=    Load Entity    building-simple-attributes-sample.jsonld      ${first_entity_id}
    ${second_entity}=    Load Entity    building-simple-attributes-sample.jsonld      ${second_entity_id}
    @{entities_to_be_created}=  Create List   ${first_entity}     ${second_entity}

    Batch Create Entities   @{entities_to_be_created}

    @{expected_entities_ids}=  Create List   ${first_entity_id}     ${second_entity_id}
    Check Response Status Code Set To  201
    Check Response Body Containing Array Of URIs set to  @{expected_entities_ids}

    #TODO call Batch Delete Entities
    Delete Entity by Id  ${first_entity_id}
    Delete Entity by Id  ${second_entity_id}

Create a batch of entities having multiple attributes
    [Documentation]  Check that you can create a batch of entities having multiple attributes
    [Tags]  critical

    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${second_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${first_entity}=    Load Entity    building-relationship-of-property-sample.jsonld      ${first_entity_id}
    ${second_entity}=    Load Entity    building-relationship-of-property-sample.jsonld      ${second_entity_id}
    @{entities_to_be_created}=  Create List   ${first_entity}     ${second_entity}

    Batch Create Entities   @{entities_to_be_created}

    @{expected_entities_ids}=  Create List   ${first_entity_id}     ${second_entity_id}
    Check Response Status Code Set To  201
    Check Response Body Containing Array Of URIs set to  @{expected_entities_ids}

    #TODO call Batch Delete Entities
    Delete Entity by Id  ${first_entity_id}
    Delete Entity by Id  ${second_entity_id}
