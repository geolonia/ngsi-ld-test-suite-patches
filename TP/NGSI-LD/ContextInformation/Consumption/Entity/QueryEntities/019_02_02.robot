*** Settings ***
Documentation       Check that one can query several entities via POST Interaction based on the entity type

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Create Entities
Suite Teardown      Delete Entities


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:
${building_filename}=       building-minimal-sample.jsonld
${vehicle_filename}=        vehicle-simple-attributes-sample.jsonld
${expectation_filename}=    two-vehicles-expectation.jsonld
${building_entity_type}=    https://ngsi-ld-test-suite/context#Building
${vehicle_entity_type}=     https://ngsi-ld-test-suite/context#Vehicle


*** Test Cases ***
019_02_02 Query several entities via POST Interaction based on the entities types
    [Documentation]    Check that one can query several entities via POST Interaction based on the entity type
    [Tags]    e-query    5_7_2
    ${entities_ids_to_be_compared}=    Create List    ${first_vehicle_entity_id}    ${second_vehicle_entity_id}
    ${response}=    Query Entities Via POST
    ...    entity_type=${vehicle_entity_type}
    ...    accept=${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing List Containing Entity Elements With Different Types
    ...    filename=${expectation_filename}
    ...    entities_representation_ids=${entities_ids_to_be_compared}
    ...    response_body=${response.json()}
    ...    ignore_core_context_version=True


*** Keywords ***
Create Entities
    ${building_entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Suite Variable    ${building_entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${building_filename}
    ...    ${building_entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${first_vehicle_entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    Set Suite Variable    ${first_vehicle_entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${vehicle_filename}
    ...    ${first_vehicle_entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${second_vehicle_entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    Set Suite Variable    ${second_vehicle_entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${vehicle_filename}
    ...    ${second_vehicle_entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}

Delete Entities
    Delete Entity by Id    ${building_entity_id}
    Delete Entity by Id    ${first_vehicle_entity_id}
    Delete Entity by Id    ${second_vehicle_entity_id}
