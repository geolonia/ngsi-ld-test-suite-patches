*** Settings ***
Documentation    Check that you can query several entities via POST Interaction based on the entities types
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${building_filename}=  building-minimal-sample.jsonld
${vehicle_filename}=  vehicle-simple-attributes-sample.jsonld
${expection_filename}=  building-vehicle-sample-expectation.jsonld
${building_entity_type}=  https://uri.fiware.org/ns/data-models#Building
${vehicle_entity_type}=  https://uri.fiware.org/ns/data-models#Vehicle


*** Test Cases ***                                                 
007_02_Query several entities via POST Interaction based on the entities types
    [Documentation]  Check that you can query several entities via POST Interaction based on the entities types
    [Tags]  mandatory    failing

    ${building_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${building_filename}     ${building_entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}
    ${vehicle_entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${vehicle_filename}     ${vehicle_entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    #@{entity_types_to_be_retrieved}=  Create List   ${building_entity_type}    ${vehicle_entity_type}
    @{entity_types_to_be_retrieved}=  Create List    ${vehicle_entity_type}
    ${response}=    Query Entities Via POST    entity_types=${entity_types_to_be_retrieved}
    Check Response Status Code  200    ${response['status']}
    @{entities_ids_to_be_retrieved}=  Create List   ${building_entity_id}    ${vehicle_entity_id}
    ##Check Response Body Containing List Containing Entity elements    ${expection_filename}    ${entities_ids_to_be_retrieved}    ${response['body']}

    [Teardown]  Delete Entities    ${building_entity_id}    ${vehicle_entity_id}


*** Keywords ***
Delete Entities
    [Arguments]  ${building_entity_id}    ${vehicle_entity_id}
    Delete Entity by Id Returning Response   ${building_entity_id}
    Delete Entity by Id Returning Response   ${vehicle_entity_id}