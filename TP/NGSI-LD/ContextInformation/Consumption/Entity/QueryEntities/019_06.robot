*** Settings ***
Documentation       Check that you can query entities specifying a maximum number of results

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Teardown      Delete Entities


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:
${filename}=                building-minimal-sample.jsonld
${entity_type}=             https://ngsi-ld-test-suite/context#Building
${limit}=                   2


*** Test Cases ***
019_06_01 Query entities specifying a maximum number of results
    [Documentation]    Check that you can query entities specifying a maximum number of results
    [Tags]    e-query    6_3_10
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
    ${third_entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Suite Variable    ${third_entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${third_entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${entities_ids_to_be_retrieved}=    Catenate
    ...    SEPARATOR=,
    ...    ${first_entity_id}
    ...    ${second_entity_id}
    ...    ${third_entity_id}
    ${entity_types_to_be_retrieved}=    Catenate    SEPARATOR=,    ${entity_type}
    ${response}=    Query Entities
    ...    entity_ids=${entities_ids_to_be_retrieved}
    ...    entity_types=${entity_types_to_be_retrieved}
    ...    limit=${limit}
    Check Response Status Code    200    ${response.status_code}
    @{entities_ids_to_be_compared}=    Create List    ${first_entity_id}    ${second_entity_id}
    Check Response Body Containing Number Of Entities    ${entity_type}    ${2}    ${response.json()}


*** Keywords ***
Delete Entities
    Delete Entity by Id    ${first_entity_id}
    Delete Entity by Id    ${second_entity_id}
    Delete Entity by Id    ${third_entity_id}
