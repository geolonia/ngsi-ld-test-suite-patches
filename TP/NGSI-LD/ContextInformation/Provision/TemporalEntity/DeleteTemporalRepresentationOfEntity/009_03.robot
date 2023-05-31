*** Settings ***
Documentation       Check that an error is raised if you delete a temporal entity with a non-existing/invalid EntityId

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource


*** Variables ***
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:
${status_code}=             404


*** Test Cases ***
009_03 Delete a temporal representation of an entity with an unknown entity id
    [Documentation]    Check that an error is raised if you delete a temporal entity with a non-existing entity id
    [Tags]    te-delete    5_6_16
    ${temporal_entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    ${response}=    Delete Temporal Representation Of Entity With Returning Response    ${temporal_entity_id}
    Check Response Status Code    ${status_code}    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response}
    ...    ${ERROR_TYPE_RESOURCE_NOT_FOUND}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}
