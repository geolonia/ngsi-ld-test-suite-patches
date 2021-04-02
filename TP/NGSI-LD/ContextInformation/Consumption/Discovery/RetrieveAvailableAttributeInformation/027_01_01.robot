*** Settings ***
Documentation   Check that you cannot retrieve a detailed representation of an unknown NGSI-LD attribute
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Suite Setup      Setup Initial Entities
Suite Teardown      Delete Initial Entities

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:
${filename}=  building-simple-attributes-sample.json

*** Test Case ***
Retrieve Detailed Representation Of Available Attribute Without Context
    [Documentation]  Check that you cannot retrieve a detailed representation of an unknown NGSI-LD attribute
    [Tags]   ed-attr    5_7_10

    Retrieve Attribute   attribute_name=airQualityLevel

    Check Response Status Code Set To  404
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_RESOURCE_NOT_FOUND}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}

*** Keywords ***
Setup Initial Entities
    ${entity_id}=     Generate Random Entity Id    ${building_id_prefix}

    Create Entity Selecting Content Type  ${filename}     ${entity_id}    ${CONTENT_TYPE_JSON}    ${ngsild_test_suite_context}

    Set Suite Variable  ${entity_id}

Delete Initial Entities
    Delete Entity by Id Returning Response   ${entity_id}
