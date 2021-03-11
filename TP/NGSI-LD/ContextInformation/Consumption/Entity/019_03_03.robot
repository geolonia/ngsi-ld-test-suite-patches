*** Settings ***
Documentation   Check that you cannot query entities if the requested id pattern is incorrect
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:
${filename}=  building-minimal-sample.jsonld
${entity_type}=  https://ngsi-ld-test-suite/context#Building
${invalid_entity_id_pattern}=  invalid_entity_id_pattern*

*** Test Cases ***                                                 
Query several entities based on incorrect id pattern
    [Documentation]  Check that you cannot query entities if the requested id pattern is incorrect
    [Tags]  /entities/    5_7_2

    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${first_entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}
    ${second_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${second_entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${entity_types_to_be_retrieved}=  Catenate    SEPARATOR=,   ${entity_type}
    ${response}=    Query Entities    entity_id_pattern=${invalid_entity_id_pattern}    entity_types=${entity_types_to_be_retrieved}
    Check Response Status Code  400    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}

    [Teardown]  Delete Entities    ${first_entity_id}    ${second_entity_id}


*** Keywords ***
Delete Entities
    [Arguments]  ${first_entity_id}    ${second_entity_id}
    Delete Entity by Id Returning Response   ${first_entity_id}
    Delete Entity by Id Returning Response   ${second_entity_id}