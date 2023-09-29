*** Settings ***
Documentation       Check that you can get an entity by id

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption/ApiUtils.resource
# Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Teardown      Delete Created Entity


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:
${filename}=                building-simple-attributes-sample.jsonld
${expectation_filename}=    building-simple-attributes-expectation.jsonld


*** Test Cases ***
018_01_01 Get an entity by id
    [Documentation]    Check that you can get an entity by id
    [Tags]    e-retrieve    5_7_1
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Suite Variable    ${entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Query Entity    ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing Entity element    ${expectation_filename}    ${entity_id}    ${response.json()}


*** Keywords ***
Delete Created Entity
    Delete Entity by Id Returning Response    ${entity_id}
