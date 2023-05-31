*** Settings ***
Documentation       Check that an error is raised if you delete a temporal entity with an unknown EntityId/Attribute Id

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Create Id
Test Template       Delete Attribute


*** Variables ***
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:
${filename}=                vehicle-temporal-representation-sample.jsonld
${status_code}=             404


*** Test Cases ***    ENTITY_ID    ATTRIBUTE_ID
015_03_01_Delete an attribute to a temporal entity if the entity id does not exist
    ${unknown_temporal_entity_id}    fuelLevel
015_03_02_Delete an attribute to a temporal entity if the entity does not contain the target attribute
    ${valid_temporal_entity_id}    notExistingAttribute


*** Keywords ***
Delete Attribute
    [Documentation]    Check that an error is raised if you delete a temporal entity with an unknown EntityId/Attribute Id
    [Tags]    tea-delete    5_6_13
    [Arguments]    ${entity_id}    ${attribute_id}
    ${response}=    Create Or Update Temporal Representation Of Entity Selecting Content Type
    ...    ${valid_temporal_entity_id}
    ...    ${filename}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response['status']}
    ${response}=    Delete Attribute From Temporal Entity
    ...    ${entity_id}
    ...    ${attribute_id}
    ...    ${CONTENT_TYPE_JSON}
    ...    ${EMPTY}
    ...    false
    ...    ${ngsild_test_suite_context}
    Check Response Status Code    ${status_code}    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response}
    ...    ${ERROR_TYPE_RESOURCE_NOT_FOUND}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}
    [Teardown]    Delete Temporal Representation Of Entity    ${valid_temporal_entity_id}

Create Id
    ${valid_temporal_entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    ${unknown_temporal_entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    Set Suite Variable    ${valid_temporal_entity_id}
    Set Suite Variable    ${unknown_temporal_entity_id}
