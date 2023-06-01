*** Settings ***
Documentation       Check that you can delete an entity by id

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:


*** Test Cases ***
Delete an entity
    [Documentation]    Check that you can delete an entity by id
    [Tags]    e-delete    5_6_6
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    ${response}=    Create Entity Selecting Content Type
    ...    building-simple-attributes-sample.jsonld
    ...    ${entity_id}
    ...    application/ld+json
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Delete Entity by Id Returning Response    ${entity_id}
    Check Response Status Code    204    ${response.status_code}
    ${response}=    Retrieve Entity by Id    ${entity_id}    context=${ngsild_test_suite_context}
    Check SUT Not Containing Resource
