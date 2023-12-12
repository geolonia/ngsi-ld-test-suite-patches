*** Settings ***
Documentation       Check that you cannot delete an attribute from an entity with invalid/missing ids

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Teardown       Delete Initial Entity
Test Template       Delete Attributes


*** Variables ***
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:
${filename}=                vehicle-two-datasetid-attributes-sample.jsonld


*** Test Cases ***    ENTITY_ID    ATTRIBUTE_ID    EXPECTED_STATUS_CODE
013_02_01 Delete an attribute if the Entity Id is not present
    ${EMPTY}    speed    400
013_02_02 Delete an attribute if the Entity Id is not a valid URI
    thisIsAnInvalidURI    speed    400
013_02_03 Delete an attribute if the Attribute Name is not present
    ${valid_entity_id}    ${EMPTY}    405


*** Keywords ***
Delete Attributes
    [Documentation]    Check that you cannot delete an attribute from an entity with invalid/missing ids
    [Tags]    ea-delete    5_6_5
    [Arguments]    ${entity_id}    ${attribute_id}    ${expected_status_code}
    ${valid_entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    Set Test Variable    ${valid_entity_id}
    ${create_response}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${valid_entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${create_response.status_code}
    ${response}=    Delete Entity Attributes
    ...    entityId=${entity_id}
    ...    attributeId=${attribute_id}
    ...    datasetId=${EMPTY}
    ...    deleteAll=false
    Check Response Status Code    ${expected_status_code}    ${response.status_code}

Delete Initial Entity
    Delete Entity by Id    ${valid_entity_id}
