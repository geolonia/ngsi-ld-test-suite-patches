*** Settings ***
Documentation   Check that you can query entitites based on a list of properties
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:
${filename}=  building-location-attribute-sample.jsonld
${expectation_filename}=  building-location-attribute-sample-expectation-query-geoproperty.jsonld
${entity_type}=  https://ngsi-ld-test-suite/context#Building
${geometry_property}=  location

*** Test Cases ***                                                 
Query several entities based on a list of properties
    [Documentation]  Check that you can query entitites based on a list of properties
    [Tags]  mandatory

    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${first_entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}
    ${second_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${second_entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    @{entities_ids_to_be_retrieved}=  Create List   ${first_entity_id}    ${second_entity_id}
    @{entity_types_to_be_retrieved}=  Create List   ${entity_type}
    ${response}=    Query Entities    entity_types=${entity_types_to_be_retrieved}    geoproperty=${geometry_property}
    Check Response Status Code  200    ${response['status']}
    Check Response Body Containing List Containing Entity elements    ${expectation_filename}    ${entities_ids_to_be_retrieved}    ${response['body']}

    [Teardown]  Delete Entities    ${first_entity_id}    ${second_entity_id}


*** Keywords ***
Delete Entities
    [Arguments]  ${first_entity_id}    ${second_entity_id}
    Delete Entity by Id Returning Response   ${first_entity_id}
    Delete Entity by Id Returning Response   ${second_entity_id}