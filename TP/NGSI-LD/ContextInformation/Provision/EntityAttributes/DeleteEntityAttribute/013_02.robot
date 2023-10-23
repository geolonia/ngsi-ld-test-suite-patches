*** Settings ***
Documentation       Check that you cannot delete an attribute from an entity with invalid/missing ids

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision/ApiUtils.resource
# Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Setup Initial Entities
Test Teardown       Delete Initial Entities
Test Template       Delete Attributes


*** Variables ***
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:
${status_code}=             400
${filename}=                vehicle-two-datasetid-attributes-sample.jsonld


*** Test Cases ***    ENTITY_ID    ATTRIBUTE_ID
013_02_01 delete an attribute if the Entity Id is not present
    ${EMPTY}    speed
013_02_02 delete an attribute if the Entity Id is not a valid URI
    thisIsAnInvalidURI    speed
013_02_03 delete an attribute if the Attribute Name is not present
    ${valid_entity_id}    ${EMPTY}


*** Keywords ***
Delete Attributes
    [Documentation]    Check that you cannot delete an attribute from an entity with invalid/missing ids
    [Tags]    ea-delete    5_6_5
    [Arguments]    ${entity_id}    ${attribute_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${valid_entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Delete Entity Attributes
    ...    entityId=${entity_id}
    ...    attributeId=${attribute_id}
    ...    datasetId=${EMPTY}
    ...    deleteAll=false
    Check Response Status Code    ${status_code}    ${response.status_code}

Setup Initial Entities
    ${valid_entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    Set Test Variable    ${valid_entity_id}

Delete Initial Entities
    Delete Entity by Id Returning Response    ${valid_entity_id}
