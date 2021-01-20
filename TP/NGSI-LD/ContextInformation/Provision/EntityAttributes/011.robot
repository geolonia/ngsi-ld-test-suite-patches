*** Settings ***
Documentation   Check that you cannot delete an attribute from an entity with invalid/missing ids
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Suite Setup      Setup Initial Entities
Test Template  Append Attributes

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${status_code}=  400
${filename}=  vehicle-two-datasetid-attributes-sample.jsonld

*** Test Cases ***                                                     ENTITY_ID                                    ATTRIBUTE_ID 
011_01_delete an attribute if the Entity Id is not present             ${EMPTY}                                     speed  
011_02_delete an attribute if the Entity Id is not a valid URI         thisIsAnInvalidURI                           speed 
011_03_delete an attribute if the Attribute Name is not present        ${valid_entity_id}                           ${EMPTY}   

*** Keywords ***
Append Attributes
    [Arguments]  ${entity_id}    ${attribute_id}
    [Documentation]  Check that you cannot delete an attribute from an entity with invalid/missing ids
    [Tags]  mandatory  failing

    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Delete Entity Attributes    ${entity_id}    ${attribute_id}    ${CONTENT_TYPE_LD_JSON}    ${EMPTY}    ${EMPTY}
    Check Response Status Code  ${status_code}    ${response['status']}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}

Setup Initial Entities
    ${valid_entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    Set Suite Variable  ${valid_entity_id}