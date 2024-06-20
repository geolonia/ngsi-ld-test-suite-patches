*** Settings ***
Documentation       Check that one can delete an entity by id

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:


*** Test Cases ***
002_01_01 Delete an entity
    [Documentation]    Check that one can delete an entity by id
    [Tags]    e-delete    5_6_6
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    ${response}=    Create Entity Selecting Content Type
    ...    building-simple-attributes-sample.jsonld
    ...    ${entity_id}
    ...    application/ld+json
    Check Response Status Code    201    ${response.status_code}
    ${response1}=    Delete Entity by Id    ${entity_id}
    Check Response Status Code    204    ${response1.status_code}
    ${response2}=    Retrieve Entity by Id    id=${entity_id}    context=${ngsild_test_suite_context}
    Check SUT Not Containing Resource    ${response2.status_code}
