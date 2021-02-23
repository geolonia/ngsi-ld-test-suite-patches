*** Settings ***
Documentation   Check that an error is raised if you delete a temporal enitity with a non existing/invalid EnityId
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${status_code}=  404

*** Test Cases ***                                                    
009_03 Delete a temporal representation of an entity with a unknown entity id  
    [Documentation]  Check that an error is raised if you delete a temporal enitity with a non existing/invalid EnityId
    [Tags]  mandatory

    ${temporal_entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}

    ${response}=  Delete Temporal Representation Of Entity With Returning Response    ${temporal_entity_id}
    Check Response Status Code  ${status_code}    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${problem_type}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}