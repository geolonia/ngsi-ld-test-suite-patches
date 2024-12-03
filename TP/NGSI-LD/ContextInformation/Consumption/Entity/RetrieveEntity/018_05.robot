*** Settings ***
Documentation       Check that the queried entity by id can be returned in a GeoJSON format

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Create Initial Entity
Suite Teardown      Delete Created Entity
Test Template       Retrieve Entity In GeoJSON Representation


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:
${filename}=                building-two-geometry-attributes.jsonld


*** Test Cases ***    OPTIONS    EXPECTATION_FILENAME
018_05_01 Simplified
    [Tags]    e-retrieve    6_3_7
    keyValues    ${EMPTY}    building-two-geometry-attribute-simplified.geojson
018_05_02 Normalized
    [Tags]    e-retrieve    6_3_7
    ${EMPTY}    ${EMPTY}    building-two-geometry-attribute-normalized.geojson
018_05_03 with geometryProperty
    [Tags]    e-retrieve    6_3_7
    ${EMPTY}    observationSpace    building-two-geometry-property-on-observation-space.geojson


*** Keywords ***
Retrieve Entity In GeoJSON Representation
    [Documentation]    Check that the queried entity by id can be returned in a GeoJSON format
    [Arguments]    ${options}    ${geometry_property}    ${expectation_filename}
    ${response}=    Query Entity
    ...    id=${entity_id}
    ...    accept=${CONTENT_TYPE_GEOJSON}
    ...    options=${options}
    ...    context=${ngsild_test_suite_context}
    ...    geometryProperty=${geometry_property}
    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing Entity element    ${expectation_filename}    ${entity_id}    ${response.json()}

Create Initial Entity
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Suite Variable    ${entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}

Delete Created Entity
    Delete Entity by Id    ${entity_id}
