*** Settings ***
Documentation       Check that you can retrieve a list with a detailed representation of NGSI-LD attributes

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Setup Initial Entities
Suite Teardown      Delete Initial Entities


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:
${filename}=                building-simple-attributes-sample.json
${expectation_file}=        types/expectations/attribute-027-01-expectation.json


*** Test Cases ***
027_02_01 Retrieve Detailed Representation Of Available Attribute
    [Documentation]    Check that you can retrieve a list with a detailed representation of NGSI-LD attributes
    [Tags]    ed-attr    5_7_10
    ${response}=    Retrieve Attribute    attribute_name=airQualityLevel    context=${ngsild_test_suite_context}
    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing Attribute element    ${expectation_file}    ${response.json()}


*** Keywords ***
Setup Initial Entities
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_JSON}
    ...    ${ngsild_test_suite_context}
    Set Suite Variable    ${entity_id}

Delete Initial Entities
    Delete Entity by Id    ${entity_id}
