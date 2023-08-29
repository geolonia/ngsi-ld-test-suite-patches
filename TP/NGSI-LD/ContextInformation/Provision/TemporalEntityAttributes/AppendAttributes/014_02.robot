*** Settings ***
Documentation       Check that an error is raised if you delete a temporal entity with empty/invalid content

Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationProvision/ApiUtils.resource
# Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource


*** Variables ***
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:
${filename}=                vehicle-temporal-representation-sample.jsonld
${fragment_filename}=       vehicle-temporal-representation-fragment.jsonld
${status_code}=             400


*** Test Cases ***
014_02_01_Add an attribute to a temporal representation of an entity with invalid content
    Add an Attribute To a Temporal Entity From File    vehicle-temporal-representation-invalid-json-fragment.jsonld

014_02_02_Add an attribute to a temporal representation of an entity with empty content
    Add an Attribute To a Temporal Entity From File    vehicle-temporal-representation-empty-json-fragment.jsonld

014_02_03_Add an attribute to a temporal representation of an entity with an empty entity id
    Add Attribute To Temporal Entity    ${EMPTY}

014_02_04_Add an attribute to a temporal representation of an entity with an invalid entity id
    Add Attribute To Temporal Entity    thisIsAninvalidId


*** Keywords ***
Add an Attribute To a Temporal Entity From File
    [Documentation]    Check that an error is raised if you add a temporal entity attribute with empty/invalid content
    [Tags]    tea-append    5_6_12
    [Arguments]    ${update_filename}
    ${temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    ${response}=    Create Or Update Temporal Representation Of Entity Selecting Content Type
    ...    ${temporal_entity_representation_id}
    ...    ${filename}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Append Attribute To Temporal Entity
    ...    ${temporal_entity_representation_id}
    ...    ${update_filename}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    ${status_code}    ${response.status_code}
    Check Response Body Type When Using Session Request    ${response.json()}    ${ERROR_TYPE_INVALID_REQUEST}
    Check Response Body Title When Using Session Request    ${response.json()}
    [Teardown]    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}

Add Attribute To Temporal Entity
    [Documentation]    Check that an error is raised if you add a temporal entity attribute with a non-existing/invalid EntityId
    [Tags]    tea-append    5_6_12
    [Arguments]    ${id}
    ${temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    ${response}=    Create Or Update Temporal Representation Of Entity Selecting Content Type
    ...    ${temporal_entity_representation_id}
    ...    ${filename}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Append Attribute To Temporal Entity    ${id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    ${status_code}    ${response.status_code}
    [Teardown]    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
