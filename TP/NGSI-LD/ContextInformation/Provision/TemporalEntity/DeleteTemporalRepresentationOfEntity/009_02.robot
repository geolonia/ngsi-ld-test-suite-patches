*** Settings ***
Documentation       Check that an error is raised if you delete a temporal entity with an empty/invalid EntityId

Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Template       Delete Temporal Entity


*** Variables ***
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:


*** Test Cases ***    STATUS_CODE    ID    PROBLEM_TYPE
009_02_01 Delete a temporal representation of an entity with an empty entity id
    400    ${EMPTY}    ${ERROR_TYPE_BAD_REQUEST_DATA}
009_02_02 Delete a temporal representation of an entity with an invalid entity id
    400    invalidId    ${ERROR_TYPE_BAD_REQUEST_DATA}


*** Keywords ***
Delete Temporal Entity
    [Documentation]    Check that an error is raised if you delete a temporal entity with an empty/invalid EntityId
    [Tags]    te-delete    5_6_16
    [Arguments]    ${status_code}    ${id}    ${problem_type}
    ${response}=    Delete Temporal Representation Of Entity With Returning Response    ${id}
    Check Response Status Code    ${status_code}    ${response.status_code}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()}
    ...    ${problem_type}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}
