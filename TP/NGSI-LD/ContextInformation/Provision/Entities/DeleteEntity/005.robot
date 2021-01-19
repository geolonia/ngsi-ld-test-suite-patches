*** Settings ***
Documentation   Check that you cannot delete an entity with invalid/missing id
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Delete Entity Scenarios

*** Variable ***
${entity_id_empty}=        
${entity_id_not_valid}=     thisisaninvaliduri

*** Test Cases ***                                                  ENTITY_ID                     EXPECTED_STATUS_CODE       PROBLEM_TYPE                      
005_01_Delete an entity if the Entity Id is not present             ${entity_id_empty}            400                        ${ERROR_TYPE_BAD_REQUEST_DATA}
005_02_Delete an entity if the Entity Id is not a valid URI         ${entity_id_not_valid}        400                        ${ERROR_TYPE_BAD_REQUEST_DATA}



*** Keywords ***
Delete Entity Scenarios
    [Arguments]  ${entity_id}    ${expected_status_code}    ${problem_type}
    [Documentation]  Check that you cannot delete an entity with invalid/missing id
    [Tags]  mandatory

    ${response}=    Delete Entity by Id Returning Response   ${entity_id}
    Check Response Status Code  ${expected_status_code}    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${problem_type}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}