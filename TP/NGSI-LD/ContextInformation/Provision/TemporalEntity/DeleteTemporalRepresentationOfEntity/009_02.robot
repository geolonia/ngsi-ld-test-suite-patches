*** Settings ***
Documentation       Check that an error is raised if one deletes a temporal entity with an empty/invalid EntityId

Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Template       Delete Temporal Entity


*** Variables ***
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:


*** Test Cases ***    ID    EXPECTED_STATUS_CODE    PROBLEM_TYPE
009_02_01 Delete a temporal representation of an entity with an empty entity id
    ${EMPTY}    405    ${EMPTY}
009_02_02 Delete a temporal representation of an entity with an invalid entity id
    invalidId    400    ${ERROR_TYPE_BAD_REQUEST_DATA}


*** Keywords ***
Delete Temporal Entity
    [Documentation]    Check that an error is raised if one deletes a temporal entity with an empty/invalid EntityId
    [Tags]    te-delete    5_6_16
    [Arguments]    ${id}    ${expected_status_code}    ${problem_type}
    ${response}=    Delete Temporal Representation Of Entity With Returning Response    ${id}
    Check Response Status Code    ${expected_status_code}    ${response.status_code}
    IF    "${problem_type}"!="${EMPTY}"
        Check Response Body Containing ProblemDetails Element Containing Type Element set to
        ...    ${response.json()}
        ...    ${problem_type}
        Check Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}
    END
