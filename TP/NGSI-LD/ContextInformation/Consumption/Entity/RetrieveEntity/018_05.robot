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
${filename}=                building-location-attribute-sample.jsonld


*** Test Cases ***    OPTIONS    EXPECTATION_FILENAME
018_05_01_Simplified    [Tags]    e-retrieve    6_3_7
    keyValues    building-location-attribute-simplified.geojson
018_05_02_Normalized    [Tags]    e-retrieve    6_3_7
    ${EMPTY}    building-location-attribute-normalized.geojson


*** Keywords ***
Retrieve Entity In GeoJSON Representation
    [Documentation]    Check that the queried entity by id can be returned in a GeoJSON format
    [Tags]    e-retrieve    6_3_7
    [Arguments]    ${options}    ${expectation_filename}
    ${response}=    Query Entity
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_GEOJSON}
    ...    options=${options}
    ...    context=${ngsild_test_suite_context}
    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing Entity element    ${expectation_filename}    ${entity_id}    ${response.json()}

Create Initial Entity
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Suite Variable    ${entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}

Delete Created Entity
    Delete Entity by Id    ${entity_id}
