*** Settings ***
Documentation       Check that one cannot query entities if the requested entity types are incorrect

Resource            ${EXECDIR}/resources/ApiUtils/Common.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Create Entities
Suite Teardown      Delete Entities


*** Variables ***
${building_filename}=           building-minimal.jsonld
${vehicle_filename}=            vehicle-simple-attributes.jsonld
${invalid_entity_type_one}=     type
${invalid_entity_type_two}=     invalid_entity_type_two


*** Test Cases ***
019_03_02 Query entities based on incorrect entity types
    [Documentation]    Check that one cannot query entities if the requested entity types are incorrect
    [Tags]    e-query    5_7_2
    ${entity_types_to_be_retrieved}=    Catenate
    ...    SEPARATOR=,
    ...    ${invalid_entity_type_one}
    ...    ${invalid_entity_type_two}

    ${response}=    Query Entities    entity_types=${entity_types_to_be_retrieved}

    Check Response Status Code    400    ${response.status_code}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()}
    ...    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}


*** Keywords ***
Create Entities
    ${building_entity_id}=    Generate Random Building Entity Id
    Set Suite Variable    ${building_entity_id}
    ${create_response1}=    Create Entity Selecting Content Type
    ...    ${building_filename}
    ...    ${building_entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${create_response1.status_code}
    ${vehicle_entity_id}=    Generate Random Vehicle Entity Id
    Set Suite Variable    ${vehicle_entity_id}
    ${create_response2}=    Create Entity Selecting Content Type
    ...    ${vehicle_filename}
    ...    ${vehicle_entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${create_response2.status_code}

Delete Entities
    Delete Entity by Id    ${building_entity_id}
    Delete Entity by Id    ${vehicle_entity_id}
