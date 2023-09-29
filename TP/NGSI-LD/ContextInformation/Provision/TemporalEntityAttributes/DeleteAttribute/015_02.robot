*** Settings ***
Documentation       Check that an error is raised if you delete an attribute to temporal entity with an unknown/invalid Entity/Attribute Id

Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Create Temporal Entity
Test Teardown       Delete Temporal Entity
Test Template       Delete attribute from temporal entity with unknow entity/attribute id


*** Variables ***
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:
${status_code}=             400
${filename}=                vehicle-temporal-representation-sample.jsonld


*** Test Cases ***    ENTITY_ID    ATTRIBUTE_ID
015_02_01 Delete an attribute to a temporal representation of an entity with a missing entity id
    ${EMPTY}    speed
015_02_02 Delete an attribute to a temporal representation of an entity with an invalid entity id
    invalidId    speed
015_02_03 Delete an attribute to a temporal representation of an entity with an invalid attribute id
    ${valid_temporal_entity_id}    invalid(Name


*** Keywords ***
Delete attribute from temporal entity with unknow entity/attribute id
    [Documentation]    Check that an error is raised if you delete an attribute to temporal entity with an unknown/invalid Entity/Attribute Id
    [Tags]    tea-delete    5_6_13
    [Arguments]    ${entity_id}    ${attribute_id}
    ${response}=    Delete Attribute From Temporal Entity
    ...    ${entity_id}
    ...    ${attribute_id}
    ...    ${CONTENT_TYPE_JSON}
    ...    ${EMPTY}
    ...    false
    Check Response Status Code    ${status_code}    ${response.status_code}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()}
    ...    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}

Create Temporal Entity
    ${valid_temporal_entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    ${response}=    Create Or Update Temporal Representation Of Entity Selecting Content Type
    ...    ${valid_temporal_entity_id}
    ...    ${filename}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    Set Test Variable    ${valid_temporal_entity_id}

Delete Temporal Entity
    Delete Temporal Representation Of Entity    ${valid_temporal_entity_id}
