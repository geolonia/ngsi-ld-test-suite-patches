*** Settings ***
Documentation   Check that you can query several entities via POST Interaction based on the given id pattern
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:
${filename}=  building-minimal-sample.jsonld
${expectation_filename}=  building-minimal-sample-expectation.jsonld
${entity_type}=  https://ngsi-ld-test-suite/context#Building
${entity_id_pattern}=  urn:ngsi-ld:Building:.*

*** Test Cases ***                                                 
Query several entities via POST Interaction based on the given id pattern
    [Documentation]  Check that you can query several entities via POST Interaction based on the given id pattern
    [Tags]  mandatory

    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${first_entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}
    ${second_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${second_entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    @{entities_ids_to_be_compared}=  Create List   ${first_entity_id}    ${second_entity_id}
    ${entities_ids_to_be_retrieved}=  Catenate    SEPARATOR=,   ${first_entity_id}    ${second_entity_id}
    @{entity_types_to_be_retrieved}=  Create List   ${entity_type}
    ${response}=    Query Entities Via POST    entity_id_pattern=${entity_id_pattern}    entity_types=${entity_types_to_be_retrieved}
    Check Response Status Code  200    ${response['status']}
    Check Response Body Containing List Containing Entity elements    ${expectation_filename}    ${entities_ids_to_be_compared}    ${response['body']}

    [Teardown]  Delete Entities    ${first_entity_id}    ${second_entity_id}


*** Keywords ***
Delete Entities
    [Arguments]  ${first_entity_id}    ${second_entity_id}
    Delete Entity by Id Returning Response   ${first_entity_id}
    Delete Entity by Id Returning Response   ${second_entity_id}