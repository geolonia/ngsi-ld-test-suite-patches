*** Settings ***
Documentation       Check that the queried entities by id can be returned in GeoJSON format

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Create Initial Entities
Suite Teardown      Delete Entities


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:
${filename}=                building-location-attribute-sample.jsonld
${expectation_filename}=    two-buildings-location-attribute-normalized.geojson
${entity_type}=             https://ngsi-ld-test-suite/context#Building


*** Test Cases ***
019_05_01 Get an entity by id that can be returned in GeoJSON format
    [Documentation]    Check that the queried entities by id can be returned in GeoJSON format
    [Tags]    e-query    6_3_7
    ${entities_ids_to_be_retrieved}=    Catenate    SEPARATOR=,    ${first_entity_id}    ${second_entity_id}
    ${entity_types_to_be_retrieved}=    Catenate    SEPARATOR=,    ${entity_type}
    ${response}=    Query Entities
    ...    entity_ids=${entities_ids_to_be_retrieved}
    ...    entity_types=${entity_types_to_be_retrieved}
    ...    accept=${CONTENT_TYPE_GEOJSON}
    ...    context=${ngsild_test_suite_context}
    Check Response Status Code    200    ${response.status_code}
    Check Response Body Content
    ...    expectation_filename=${expectation_filename}
    ...    response_body=${response.json()}


*** Keywords ***
Create Initial Entities
    ${first_entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Suite Variable    ${first_entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${first_entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    ${second_entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Suite Variable    ${second_entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${second_entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}

Delete Entities
    Delete Entity by Id Returning Response    ${first_entity_id}
    Delete Entity by Id Returning Response    ${second_entity_id}
