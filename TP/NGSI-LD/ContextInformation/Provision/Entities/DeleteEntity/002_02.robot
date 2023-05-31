*** Settings ***
Documentation       Check that you cannot delete an entity with invalid/missing id

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Template       Delete Entity Scenarios


*** Test Cases ***    ENTITY_ID    EXPECTED_STATUS_CODE    PROBLEM_TYPE
002_02_01_Delete an entity if the Entity Id is not present
    ${EMPTY}    400    ${ERROR_TYPE_BAD_REQUEST_DATA}
002_02_02_Delete an entity if the Entity Id is not a valid URI
    thisisaninvaliduri    400    ${ERROR_TYPE_BAD_REQUEST_DATA}


*** Keywords ***
Delete Entity Scenarios
    [Documentation]    Check that you cannot delete an entity with invalid/missing id
    [Tags]    e-delete    5_6_6
    [Arguments]    ${entity_id}    ${expected_status_code}    ${problem_type}
    ${response}=    Delete Entity by Id Returning Response    ${entity_id}
    Check Response Status Code    ${expected_status_code}    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response}
    ...    ${problem_type}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}
