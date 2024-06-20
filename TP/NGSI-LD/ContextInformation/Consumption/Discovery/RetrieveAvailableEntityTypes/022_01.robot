*** Settings ***
Documentation       Check that one can retrieve a list of NGSI-LD entity types

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Setup Initial Entities
Test Teardown       Delete Initial Entities
Test Template       Retrieve Available Entity Types


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:
${first_filename}=          building-simple-attributes-sample.json
${second_filename}=         vehicle-simple-attributes-sample.json


*** Test Cases ***    CONTEXT    EXPECTATION_FILE
022_01_01 WithoutJsonLdContext
    [Tags]    ed-types    5_7_5
    ${EMPTY}    types/expectations/entity-type-list-022-01-01-expectation.json
022_01_02 WithJsonLdContext
    [Tags]    ed-types    5_7_5
    ${ngsild_test_suite_context}    types/expectations/entity-type-list-022-01-02-expectation.json


*** Keywords ***
Retrieve Available Entity Types
    [Documentation]    Check that one can retrieve a list of NGSI-LD entity types
    [Arguments]    ${context}    ${expectation_file}
    ${response}=    Retrieve Entity Types
    ...    context=${context}
    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing EntityTypeList element    ${expectation_file}    ${response.json()}

Setup Initial Entities
    ${first_entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    ${second_entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    Create Entity Selecting Content Type
    ...    ${first_filename}
    ...    ${first_entity_id}
    ...    ${CONTENT_TYPE_JSON}
    ...    ${ngsild_test_suite_context}
    Create Entity Selecting Content Type
    ...    ${second_filename}
    ...    ${second_entity_id}
    ...    ${CONTENT_TYPE_JSON}
    ...    ${ngsild_test_suite_context}
    Set Test Variable    ${first_entity_id}
    Set Test Variable    ${second_entity_id}

Delete Initial Entities
    Delete Entity by Id    ${first_entity_id}
    Delete Entity by Id    ${second_entity_id}
