*** Settings ***
Documentation       Check that you cannot query entities if the requested ids are incorrect

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Teardown      Delete Entities


*** Variables ***
${building_id_prefix}=          urn:ngsi-ld:Building:
${filename}=                    building-minimal-sample.jsonld
${entity_type}=                 https://ngsi-ld-test-suite/context#Building
${entity_invalid_id_one}=       thisisaninvaliduri1
${entity_invalid_id_two}=       thisisaninvaliduri2


*** Test Cases ***
Query entities based on incorrect ids
    [Documentation]    Check that you cannot query entities if the requested ids are incorrect
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
    ${entities_ids_to_be_retrieved}=    Catenate    SEPARATOR=,    ${entity_invalid_id_one}    ${entity_invalid_id_two}
    ${entity_types_to_be_retrieved}=    Catenate    SEPARATOR=,    ${entity_type}
    ${response}=    Query Entities
    ...    entity_ids=${entities_ids_to_be_retrieved}
    ...    entity_types=${entity_types_to_be_retrieved}
    Check Response Status Code    400    ${response.status_code}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()}
    ...    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}



*** Keywords ***
Delete Entities
    Delete Entity by Id Returning Response    ${first_entity_id}
    Delete Entity by Id Returning Response    ${second_entity_id}
