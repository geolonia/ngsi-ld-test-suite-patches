*** Settings ***
Documentation       Check that you cannot query entities if the request has a wrong geometryProperty

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Teardown      Delete Entities


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:
${filename}=                building-location-attribute-sample.jsonld
${entity_type}=             Building
${georel}=                  invalid
${geometry}=                Point
${coordinates}=             [-8.503,41.202]
${geoproperty}=             location


*** Test Cases ***
019_03_05 Query entities when the request has a wrong geometryProperty
    [Documentation]    Check that you cannot query entities if the request has a wrong geometryProperty
    [Tags]    e-query    5_7_2
    ${first_entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Suite Variable    ${first_entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${first_entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${second_entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Suite Variable    ${second_entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${second_entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${entity_types_to_be_retrieved}=    Catenate    SEPARATOR=,    ${entity_type}
    ${response}=    Query Entities
    ...    entity_types=${entity_types_to_be_retrieved}
    ...    geoproperty=${geoproperty}
    ...    georel=${georel}
    ...    geometry=${geometry}
    ...    coordinates=${coordinates}
    ...    context=${ngsild_test_suite_context}
    Check Response Status Code    400    ${response.status_code}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()}
    ...    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}


*** Keywords ***
Delete Entities
    Delete Entity by Id    ${first_entity_id}
    Delete Entity by Id    ${second_entity_id}
