*** Settings ***
Documentation       Check that you cannot get an entity if an attribute is not known to the system

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Teardown      Delete Created Entity


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:
${filename}=                building-simple-attributes-sample.jsonld
${attribute_not_known}=     property_not_found


*** Test Cases ***
018_03_02 Get an entity if an attribute is not known to the system
    [Documentation]    Check that you cannot get an entity if an attribute is not known to the system
    [Tags]    e-retrieve    5_7_1
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Suite Variable    ${entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${attributes_to_be_retrieved}=    Catenate    SEPARATOR=,    ${attribute_not_known}
    ${response}=    Query Entity
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    ...    attrs=${attributes_to_be_retrieved}
    Check Response Status Code    404    ${response.status_code}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()}
    ...    ${ERROR_TYPE_RESOURCE_NOT_FOUND}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}


*** Keywords ***
Delete Created Entity
    Delete Entity by Id Returning Response    ${entity_id}
