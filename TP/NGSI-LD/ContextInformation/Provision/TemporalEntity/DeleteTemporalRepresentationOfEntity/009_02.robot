*** Settings ***
Documentation   Check that an error is raised if you delete a temporal enitity with an empty/invalid EnityId
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Delete Temporal Entity

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:

*** Test Cases ***                                                                           STATUS_CODE         ID   
009_02_01_Delete a temporal representation of an entity with an empty entity id              400                 ${EMPTY}
009_02_02 Delete a temporal representation of an entity with an invalid entity id            400                 invalidId

*** Keywords ***
Delete Temporal Entity
    [Arguments]  ${status_code}    ${id}
    [Documentation]  Check that an error is raised if you delete a temporal enitity with an empty/invalid EnityId
    [Tags]  mandatory

    ${response}=  Delete Temporal Representation Of Entity With Returning Response    ${id}
    Check Response Status Code  ${status_code}    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${problem_type}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}