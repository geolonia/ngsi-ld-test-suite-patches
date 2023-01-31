*** Settings ***
Documentation     Check that you cannot delete an attribute from an entity with invalid/missing ids
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Suite Setup       Setup Initial Entities
Suite Teardown    Delete Initial Entities
Test Template     Delete Attributes

*** Variable ***
${vehicle_id_prefix}=    urn:ngsi-ld:Vehicle:
${status_code}=    404
${filename}=      vehicle-two-datasetid-attributes-sample.jsonld

*** Test Cases ***    ENTITY_ID                 ATTRIBUTE_ID    DATASETID
013_03_01_delete an attribute when the Entity Id is not known to the system
                      ${not_found_entity_id}    speed           urn:ngsi-ld:Property:gpsBxyz123-speed

013_03_02_delete an attribute when the Entity does not contain the target attribute id
                      ${valid_entity_id}        notFound        ${EMPTY}

013_03_03_delete an attribute when the Entity does not contain the target attribute with same datasetId
                      ${valid_entity_id}        speed           urn:ngsi-ld:Property:notFound

*** Keywords ***
Delete Attributes
    [Arguments]    ${entity_id}    ${attribute_id}    ${datasetId}
    [Documentation]    Check that you cannot delete an attribute from an entity with invalid/missing ids
    [Tags]    ea-delete    5_6_5
    ${response}=    Delete Entity Attributes    ${entity_id}    ${attribute_id}    ${datasetId}    false
    Check Response Status Code    ${status_code}    ${response['status']}
    [Teardown]    Delete Entity by Id Returning Response    ${entity_id}

Setup Initial Entities
    ${valid_entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    Set Suite Variable    ${valid_entity_id}
    ${request}    ${response}=    Create Entity Selecting Content Type    ${filename}    ${valid_entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response['status']}
    ${not_found_entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    Set Suite Variable    ${not_found_entity_id}

Delete Initial Entities
    Delete Entity by Id Returning Response    ${valid_entity_id}
