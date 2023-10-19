*** Settings ***
Documentation       Check that you can retrieve a list of NGSI-LD attributes

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption/ApiUtils.resource
# Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Setup Initial Entities
Test Teardown       Delete Initial Entities
Test Template       Retrieve Available Attributes


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:
${filename}=                building-simple-attributes-sample.json


*** Test Cases ***    CONTEXT    EXPECTATION_FILE
025_01_01 WithoutJsonLdContext
    [Tags]    ed-attrs    5_7_8
    ${EMPTY}    types/expectations/attribute-list-025-01-01-expectation.json
025_01_02 WithJsonLdContext
    [Tags]    ed-attrs    5_7_8
    ${ngsild_test_suite_context}    types/expectations/attribute-list-025-01-02-expectation.json


*** Keywords ***
Retrieve Available Attributes
    [Documentation]    Check that you can retrieve a list of NGSI-LD attributes
    [Arguments]    ${context}    ${expectation_file}
    ${response}=    Retrieve Attributes
    ...    context=${context}
    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing AttributeList element    ${expectation_file}    ${response.json()}

Setup Initial Entities
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_JSON}
    ...    ${ngsild_test_suite_context}
    Set Test Variable    ${entity_id}

Delete Initial Entities
    Delete Entity by Id Returning Response    ${entity_id}
