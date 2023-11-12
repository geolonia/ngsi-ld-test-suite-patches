*** Settings ***
Documentation       Check that you can query entitites via POST Interaction asking for a GeoJSON representation

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Create Entities
Suite Teardown      Delete Entities


*** Variables ***
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:
${parking_id_prefix}=       urn:ngsi-ld:OffStreetParking:
${vehicle_filename}=        vehicle-simple-attributes-sample.jsonld
${parking_filename}=        parking-simple-attributes-sample.jsonld
${expectation_filename}=    building-minimal-expectation.json
${vehicle_entity_type}=     https://ngsi-ld-test-suite/context#Vehicle
${parking_entity_type}=     https://ngsi-ld-test-suite/context#OffStreetParking
${geometry_property}=       location


*** Test Cases ***
019_02_05 Query several entities via POST Interaction asking for a GeoJSON representation
    [Documentation]    Check that you can query entitites via POST Interaction asking for a GeoJSON representation
    [Tags]    e-query    5_7_2
    @{entities_ids_to_be_compared}=    Create List    ${vehicle_entity_id}    ${parking_entity_id}
    ${entity_types_to_be_retrieved}=    Catenate    SEPARATOR=,    ${vehicle_entity_type}    ${parking_entity_type}
    ${response}=    Query Entities Via POST
    ...    entity_types=${entity_types_to_be_retrieved}
    ...    accept=${CONTENT_TYPE_GEOJSON}
    ...    geometry_property=${geometry_property}
    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing List Containing Entity elements
    ...    ${expectation_filename}
    ...    ${entities_ids_to_be_compared}
    ...    ${response.json()}


*** Keywords ***
Create Entities
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

Delete Entities
    Delete Entity by Id Returning Response    ${vehicle_entity_id}
    Delete Entity by Id Returning Response    ${parking_entity_id}
