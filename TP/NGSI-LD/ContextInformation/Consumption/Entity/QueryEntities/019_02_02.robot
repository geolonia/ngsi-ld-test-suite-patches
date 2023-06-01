*** Settings ***
Documentation       Check that you can query several entities via POST Interaction based on the entities types

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Teardown      Delete Entities


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:
${parking_id_prefix}=       urn:ngsi-ld:OffStreetParking:
${building_filename}=       building-minimal-sample.jsonld
${vehicle_filename}=        vehicle-simple-attributes-sample.jsonld
${parking_filename}=        parking-simple-attributes-sample.jsonld
${expectation_filename}=    two-types-vehicle-offstreetparking-expectation.jsonld
${building_entity_type}=    https://ngsi-ld-test-suite/context#Building
${vehicle_entity_type}=     https://ngsi-ld-test-suite/context#Vehicle
${parking_entity_type}=     https://ngsi-ld-test-suite/context#OffStreetParking


*** Test Cases ***
Query several entities via POST Interaction based on the entities types
    [Documentation]    Check that you can query several entities via POST Interaction based on the entities types
    [Tags]    e-query    5_7_2
    ${building_entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Suite Variable    ${building_entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${building_filename}
    ...    ${building_entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${vehicle_entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    Set Suite Variable    ${vehicle_entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${vehicle_filename}
    ...    ${vehicle_entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${parking_entity_id}=    Generate Random Entity Id    ${parking_id_prefix}
    Set Suite Variable    ${parking_entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${parking_filename}
    ...    ${parking_entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    @{entity_types_to_be_compared}=    Create List    ${vehicle_entity_type}    ${parking_entity_type}
    ${entity_types_to_be_retrieved}=    Catenate    SEPARATOR=,    ${vehicle_entity_type}    ${parking_entity_type}
    ${response}=    Query Entities    entity_types=${entity_types_to_be_retrieved}
    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing List Containing Entity elements
    ...    ${expectation_filename}
    ...    ${entity_types_to_be_compared}
    ...    ${response.json()}


*** Keywords ***
Delete Entities
    Delete Entity by Id Returning Response    ${building_entity_id}
    Delete Entity by Id Returning Response    ${vehicle_entity_id}
    Delete Entity by Id Returning Response    ${parking_entity_id}
