*** Settings ***
Documentation       Check that an error is raised if you delete a temporal entity with an unknown EntityId/Attribute Id

Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Create Id
Test Teardown       Delete Temporal Entity
Test Template       Delete Attribute


*** Variables ***
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:
${filename}=                vehicle-temporal-representation-sample.jsonld
${status_code}=             404


*** Test Cases ***    ENTITY_ID    ATTRIBUTE_ID
015_03_01 Delete an attribute to a temporal entity if the entity id does not exist
    ${unknown_temporal_entity_id}    fuelLevel
015_03_02 Delete an attribute to a temporal entity if the entity does not contain the target attribute
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
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Delete Attribute From Temporal Entity
    ...    ${entity_id}
    ...    ${attribute_id}
    ...    ${CONTENT_TYPE_JSON}
    ...    ${EMPTY}
    ...    false
    ...    ${ngsild_test_suite_context}
    Check Response Status Code    ${status_code}    ${response.status_code}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()}
    ...    ${ERROR_TYPE_RESOURCE_NOT_FOUND}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}

Create Id
    ${valid_temporal_entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    ${unknown_temporal_entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    Set Test Variable    ${valid_temporal_entity_id}
    Set Test Variable    ${unknown_temporal_entity_id}

Delete Temporal Entity
    Delete Temporal Representation Of Entity    ${valid_temporal_entity_id}
