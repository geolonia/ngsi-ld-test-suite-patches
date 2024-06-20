*** Settings ***
Documentation       Check that one cannot create an entity with an existing id

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Teardown      Delete Initial Entity


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:
${filename}=                building-minimal-sample.jsonld
${content_type}=            application/ld+json


*** Test Cases ***
001_03_01 Create one valid entity and one invalid entity
    [Documentation]    Check that one cannot create an entity with an existing id
    [Tags]    e-create    5_6_1
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Suite Variable    ${entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${entity_id}
    ...    ${content_type}
    Check Response Status Code    201    ${response.status_code}
    ${response1}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${entity_id}
    ...    ${content_type}
    Check Response Status Code    409    ${response1.status_code}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response1.json()}
    ...    ${ERROR_TYPE_ALREADY_EXISTS}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response1.json()}


*** Keywords ***
Delete Initial Entity
    Delete Entity by Id    ${entity_id}
