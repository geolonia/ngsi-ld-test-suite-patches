*** Settings ***
Documentation       Check that you can query several entities via POST Interaction based on the given id pattern

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Create Entities
Suite Teardown      Delete Entities


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:
${filename}=                building-minimal-sample.jsonld
${expectation_filename}=    building-minimal-expectation.json
${entity_type}=             https://ngsi-ld-test-suite/context#Building
${entity_id_pattern}=       urn:ngsi-ld:Building:.*


*** Test Cases ***
019_02_03 Query several entities via POST Interaction based on the given id pattern
    [Documentation]    Check that you can query several entities via POST Interaction based on the given id pattern
    [Tags]    e-query    5_7_2
    @{entities_ids_to_be_compared}=    Create List    ${first_entity_id}    ${second_entity_id}
    ${response}=    Query Entities Via POST
    ...    entity_id_pattern=${entity_id_pattern}
    ...    entity_type=${entity_type}
    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing List Containing Entity elements
    ...    ${expectation_filename}
    ...    ${entities_ids_to_be_compared}
    ...    ${response.json()}


*** Keywords ***
Create Entities
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

Delete Entities
    Delete Entity by Id Returning Response    ${first_entity_id}
    Delete Entity by Id Returning Response    ${second_entity_id}
