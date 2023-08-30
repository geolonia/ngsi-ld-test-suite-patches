*** Settings ***
Documentation       Check that you cannot get an entity if the entity id is not known to the system

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption/ApiUtils.resource
# Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:


*** Test Cases ***
Get an entity if the Entity Id is not known to the system
    [Documentation]    Check that you cannot get an entity if the entity id or attributes are not known to the system
    [Tags]    e-retrieve    5_7_1
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    ${response}=    Query Entity    ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    404    ${response.status_code}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()}
    ...    ${ERROR_TYPE_RESOURCE_NOT_FOUND}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}
