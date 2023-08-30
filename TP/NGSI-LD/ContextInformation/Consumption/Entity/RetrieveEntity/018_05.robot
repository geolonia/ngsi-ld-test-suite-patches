*** Settings ***
Documentation       Check that the queried entity by id can be returned in a geoJSON format

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption/ApiUtils.resource
# Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Teardown      Delete Created Entity


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:
${filename}=                building-location-attribute-sample.jsonld
${expectation_filename}=    building-simple-attributes-simplified-expectation.json
${options_parameter}=       keyValues
${accept_header}=           application/geo+json


*** Test Cases ***
Get an entity by id that can be returned in a geoJSON format
    [Documentation]    Check that the queried entity by id can be returned in a geoJSON format
    [Tags]    e-retrieve    6_3_7
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Suite Variable    ${entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Query Entity    ${entity_id}    ${accept_header}    options=${options_parameter}
    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing Entity element    ${expectation_filename}    ${entity_id}    ${response.json()}


*** Keywords ***
Delete Created Entity
    Delete Entity by Id Returning Response    ${entity_id}
