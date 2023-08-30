*** Settings ***
Documentation       Check that you can query several entities based on the given id pattern

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption/ApiUtils.resource
# Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Teardown      Delete Entities


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:
${filename}=                building-minimal-sample.jsonld
${expectation_filename}=    building-minimal-expectation.json
${entity_type}=             https://ngsi-ld-test-suite/context#Building
${entity_id_pattern}=       urn:ngsi-ld:Building:.*


*** Test Cases ***
Query several entities based on the given id pattern
    [Documentation]    Check that you can query several entities based on the given id pattern
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
    @{entities_ids_to_be_compared}=    Create List    ${second_entity_id}    ${first_entity_id}
    ${response}=    Query Entities
    ...    entity_id_pattern=${entity_id_pattern}
    ...    entity_types=${entity_types_to_be_retrieved}
    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing List Containing Entity elements
    ...    ${expectation_filename}
    ...    ${entities_ids_to_be_compared}
    ...    ${response.json()}


*** Keywords ***
Delete Entities
    Delete Entity by Id Returning Response    ${first_entity_id}
    Delete Entity by Id Returning Response    ${second_entity_id}
