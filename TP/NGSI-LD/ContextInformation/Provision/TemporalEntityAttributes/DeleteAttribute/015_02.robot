*** Settings ***
Documentation   Check that an error is raised if you delete an attribute to temporal entity with a unknown/invalid Entity/Attribute Id
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Suite Setup    Create Id
Test Template  Delete attribute from temporal entity with unknow entity/attribute id

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${status_code}=  400
${filename}=  vehicle-temporal-representation-sample.jsonld

*** Test Cases ***                                                                                         ENTITY_ID                           ATTRIBUTE_ID
015_02_01_Delete an attribute to a temporal representation of an entity with a missing entity id           ${EMPTY}                            speed
015_02_02_Delete an attribute to a temporal representation of an entity with an invalid entity id          invalidId                           speed 
015_02_03_Delete an attribute to a temporal representation of an entity with an invalid attribute id       ${valid_temporal_entity_id}         invalid(Name

*** Keywords ***
Delete attribute from temporal entity with unknow entity/attribute id
    [Arguments]  ${entity_id}    ${attribute_id}
    [Documentation]  Check that an error is raised if you delete an attribute to  temporal entity with a unknown/invalid Entity/Attribute Id
    [Tags]  tea-delete

    ${temporal_entity_representation_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${response}=  Create Or Update Temporal Representation Of Entity Selecting Content Type  ${temporal_entity_representation_id}    ${filename}     ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}


    ${response}=  Delete Attribute From Temporal Entity  ${entity_id}    ${attribute_id}     ${CONTENT_TYPE_JSON}    ${EMPTY}    false
    Check Response Status Code   ${status_code}    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_RESOURCE_NOT_FOUND}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}

    [Teardown]    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}

Create Id
    ${valid_temporal_entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    Set Suite Variable  ${valid_temporal_entity_id}