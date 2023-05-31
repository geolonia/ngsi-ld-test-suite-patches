*** Settings ***
Documentation       Check that you cannot query entities if the requested entity types are incorrect

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource


*** Variables ***
${building_id_prefix}=          urn:ngsi-ld:Building:
${vehicle_id_prefix}=           urn:ngsi-ld:Vehicle:
${building_filename}=           building-minimal-sample.jsonld
${vehicle_filename}=            vehicle-simple-attributes-sample.jsonld
${invalid_entity_type_one}=     type
${invalid_entity_type_two}=     invalid_entity_type_two


*** Test Cases ***
Query entities based on incorrect entity types
    [Documentation]    Check that you cannot query entities if the requested entity types are incorrect
    [Tags]    e-query    5_7_2
    ${building_entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type
    ...    ${building_filename}
    ...    ${building_entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response['status']}
    ${vehicle_entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type
    ...    ${vehicle_filename}
    ...    ${vehicle_entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response['status']}
    ${entity_types_to_be_retrieved}=    Catenate
    ...    SEPARATOR=,
    ...    ${invalid_entity_type_one}
    ...    ${invalid_entity_type_two}
    ${response}=    Query Entities    entity_types=${entity_types_to_be_retrieved}
    Check Response Status Code    400    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response}
    ...    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}
    [Teardown]    Delete Entities    ${building_entity_id}    ${vehicle_entity_id}


*** Keywords ***
Delete Entities
    [Arguments]    ${building_entity_id}    ${vehicle_entity_id}
    Delete Entity by Id Returning Response    ${building_entity_id}
    Delete Entity by Id Returning Response    ${vehicle_entity_id}
