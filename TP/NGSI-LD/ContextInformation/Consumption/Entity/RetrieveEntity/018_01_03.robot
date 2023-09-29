*** Settings ***
Documentation       Check that you can query the geometry property from an entity

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption/ApiUtils.resource
# Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Teardown      Delete Created Entity


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:
${filename}=                building-location-attribute-sample.jsonld
${expectation_filename}=    building-geoproperty-query-expectation.jsonld
${geometry_property}=       location


*** Test Cases ***
018_01_03 Query the geometry property from an entity
    [Documentation]    Check that you can query the geometry property from an entity
    [Tags]    e-retrieve    5_7_1
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Suite Variable    ${entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Query Entity
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    ...    geoproperty=${geometry_property}
    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing Entity element    ${expectation_filename}    ${entity_id}    ${response.json()}


*** Keywords ***
Delete Created Entity
    Delete Entity by Id Returning Response    ${entity_id}
