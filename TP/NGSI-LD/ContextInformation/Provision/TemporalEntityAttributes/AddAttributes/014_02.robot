*** Settings ***
Documentation       Check that an error is raised if you add an attribute to a temporal entity with invalid content

Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Template       Add Attribute To Temporal Entity


*** Variables ***
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:
${filename}=                vehicle-temporal-representation-sample.jsonld
${fragment_filename}=       vehicle-temporal-representation-fragment.jsonld
${status_code}=             400


*** Test Cases ***    ID
014_02_01 Add an attribute to a temporal representation of an entity with an empty entity id
    ${EMPTY}
014_02_02 Add an attribute to a temporal representation of an entity with an invalid entity id
    thisIsAninvalidId


*** Keywords ***
Add Attribute To Temporal Entity
    [Documentation]    Check that an error is raised if you add a temporal entity attribute with a non-existing/invalid EntityId
    [Tags]    tea-append    5_6_12
    [Arguments]    ${id}
    ${temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    ${response}=    Create Or Update Temporal Representation Of Entity Selecting Content Type
    ...    temporal_entity_representation_id=${temporal_entity_representation_id}
    ...    filename=${filename}
    ...    content_type=${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Append Attribute To Temporal Entity    ${id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    ${status_code}    ${response.status_code}
    [Teardown]    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
