*** Settings ***
Documentation   Check that you can query several entities based on the entities types
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${parking_id_prefix}=  urn:ngsi-ld:OffStreetParking:
${building_filename}=  building-minimal-sample.jsonld
${vehicle_filename}=  vehicle-simple-attributes-sample.jsonld
${parking_filename}=  parking-simple-attributes-sample.jsonld
${expectation_filename}=  vehicle-parking-sample-expectation.jsonld
${building_entity_type}=  https://ngsi-ld-test-suite/context#Building
${vehicle_entity_type}=  https://ngsi-ld-test-suite/context#Vehicle
${parking_entity_type}=  https://ngsi-ld-test-suite/context#OffStreetParking


*** Test Cases ***                                                 
Query several entities based on the entities types 
    [Documentation]  Check that you can query several entities based on the entities types
    [Tags]  mandatory

    ${building_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${building_filename}     ${building_entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}
    ${vehicle_entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${vehicle_filename}     ${vehicle_entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}
    ${parking_entity_id}=     Generate Random Entity Id    ${parking_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${parking_filename}     ${parking_entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${entity_types_to_be_retrieved}=  Catenate    SEPARATOR=,   ${vehicle_entity_type}    ${parking_entity_type}
    ${response}=    Query Entities    entity_types=${entity_types_to_be_retrieved}
    Check Response Status Code  200    ${response['status']}
    @{entities_ids_to_be_compared}=  Create List    ${vehicle_entity_id}    ${parking_entity_id}
    Check Response Body Containing List Containing Entity Elements With Different Types    ${expectation_filename}    ${entities_ids_to_be_compared}    ${response['body']}

    [Teardown]  Delete Entities    ${building_entity_id}    ${vehicle_entity_id}    ${parking_entity_id}


*** Keywords ***
Delete Entities
    [Arguments]  ${building_entity_id}    ${vehicle_entity_id}    ${parking_entity_id}
    Delete Entity by Id Returning Response   ${building_entity_id}
    Delete Entity by Id Returning Response   ${vehicle_entity_id}
    Delete Entity by Id Returning Response   ${parking_entity_id}