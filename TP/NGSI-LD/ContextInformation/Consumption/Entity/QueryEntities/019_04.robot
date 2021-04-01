*** Settings ***
Documentation   Check that the queried entities by Id can be returned in a simplified representation
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:
${filename}=  building-simple-attributes-sample.jsonld
${expectation_filename}=  building-simple-attributes-simplified-expectation.json
${options_parameter}=  keyValues
${entity_type}=  https://ngsi-ld-test-suite/context#Building

*** Test Cases ***                                                 
Query entities in a simplified representation
    [Documentation]  Check that the queried entities by Id can be returned in a simplified representation
    [Tags]  e-query    6_3_7

    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${first_entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}
    ${second_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${second_entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}
    ${third_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${third_entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    @{entities_ids_to_be_compared}=  Create List    ${first_entity_id}    ${second_entity_id}
    ${entities_ids_to_be_retrieved}=  Catenate    SEPARATOR=,   ${first_entity_id}    ${second_entity_id}
    ${entity_types_to_be_retrieved}=  Catenate    SEPARATOR=,   ${entity_type}
    ${response}=    Query Entities    entity_ids=${entities_ids_to_be_retrieved}    entity_types=${entity_types_to_be_retrieved}    options=${options_parameter}
    Check Response Status Code  200    ${response['status']}
    Check Response Body Containing List Containing Entity elements    ${expectation_filename}    ${entities_ids_to_be_compared}    ${response['body']}

    [Teardown]  Delete Entities    ${first_entity_id}    ${second_entity_id}    ${third_entity_id}


*** Keywords ***
Delete Entities
    [Arguments]  ${first_entity_id}    ${second_entity_id}    ${third_entity_id}
    Delete Entity by Id Returning Response   ${first_entity_id}
    Delete Entity by Id Returning Response   ${second_entity_id}
    Delete Entity by Id Returning Response   ${third_entity_id}