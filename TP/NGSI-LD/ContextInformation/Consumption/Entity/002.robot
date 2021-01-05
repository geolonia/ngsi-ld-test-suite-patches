*** Settings ***
Documentation   Check that you cannot get an entity with invalid/missing id
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource

Test Template  Get Entity With Invalid/Missing Id

*** Test Cases ***                                                  ENTITY_ID                     EXPECTED_STATUS_CODE       PROBLEM_TYPE                      
002_01_Get an entity if the Entity Id is not present                ${EMPTY}                      400                        ${ERROR_TYPE_BAD_REQUEST_DATA}
002_02_Get an entity if the Entity Id is not a valid URI            thisisaninvaliduri            400                        ${ERROR_TYPE_BAD_REQUEST_DATA}

*** Keywords ***                               
Get Entity With Invalid/Missing Id
    [Arguments]  ${entity_id}    ${expected_status_code}    ${problem_type}
    [Documentation]  Check that you cannot get an entity with invalid/missing id
    [Tags]  mandatory    failing

    ${response}=    Query Entity    ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  ${expected_status_code}    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${problem_type}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}