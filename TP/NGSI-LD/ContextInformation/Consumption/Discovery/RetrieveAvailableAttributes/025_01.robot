*** Settings ***
Documentation       Check that you can retrieve a list of NGSI-LD attributes

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Setup Initial Entities
Suite Teardown      Delete Initial Entities
Test Template       Retrieve Available Attributes


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:
${filename}=                building-simple-attributes-sample.json


*** Test Cases ***    CONTEXT    EXPECTATION_FILE
WithoutJsonLdContext
    [Tags]    ed-attrs    5_7_8
    ${EMPTY}    types/expectations/attribute-list-025-01-01-expectation.json
WithJsonLdContext    [Tags]    ed-attrs    5_7_8
    ${ngsild_test_suite_context}    types/expectations/attribute-list-025-01-02-expectation.json


*** Keywords ***
Retrieve Available Attributes
    [Documentation]    Check that you can retrieve a list of NGSI-LD attributes
    [Arguments]    ${context}    ${expectation_file}
    ${response}=    Retrieve Attributes    ${context}
    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing AttributeList element    ${expectation_file}    ${response.json()}

Setup Initial Entities
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_JSON}
    ...    ${ngsild_test_suite_context}
    Set Suite Variable    ${entity_id}

Delete Initial Entities
    Delete Entity by Id Returning Response    ${entity_id}
