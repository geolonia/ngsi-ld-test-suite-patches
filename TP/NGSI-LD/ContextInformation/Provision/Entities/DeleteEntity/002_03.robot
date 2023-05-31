*** Settings ***
Documentation       Check that you cannot delete an entity if the entity id is not known to the system

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:
${expected_status_code}=    404


*** Test Cases ***
Delete an entity with an id not known to the system
    [Documentation]    Check that you cannot delete an entity if the entity id is not known to the system
    [Tags]    e-delete    5_6_6
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    ${response}=    Delete Entity by Id Returning Response    ${entity_id}
    Check Response Status Code    ${expected_status_code}    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response}
    ...    ${ERROR_TYPE_RESOURCE_NOT_FOUND}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}
