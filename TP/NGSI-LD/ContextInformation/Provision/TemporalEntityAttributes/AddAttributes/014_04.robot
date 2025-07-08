*** Settings ***
Documentation       Check that an error is raised if one adds a temporal entity attribute with empty/invalid content

Resource            ${EXECDIR}/resources/ApiUtils/Common.resource
Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Initialize Test Case
Test Teardown       Delete Temporal Entity
Test Template       Add an Attribute To a Temporal Entity From File


*** Variables ***
${filename}=                vehicle-temporal-representation.jsonld
${fragment_filename}=       vehicle-temporal-representation-fragment.jsonld
${status_code}=             400


*** Test Cases ***    UPDATE_FILENAME
014_04_01 Add an attribute to a temporal representation of an entity with invalid content
    vehicle-temporal-representation-invalid-json-fragment.jsonld
014_04_02 Add an attribute to a temporal representation of an entity with empty content
    vehicle-temporal-representation-empty-json-fragment.jsonld


*** Keywords ***
Add an Attribute To a Temporal Entity From File
    [Documentation]    Check that an error is raised if one adds a temporal entity attribute with empty/invalid content
    [Tags]    tea-append    5_6_12
    [Arguments]    ${update_filename}
    ${response}=    Append Attribute To Temporal Entity
    ...    ${temporal_entity_representation_id}
    ...    ${update_filename}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    ${status_code}    ${response.status_code}
    Check Response Body Type When Using Session Request    ${response.json()}    ${ERROR_TYPE_INVALID_REQUEST}
    Check Response Body Title When Using Session Request    ${response.json()}

Initialize Test Case
    ${temporal_entity_representation_id}=    Generate Random Vehicle Entity Id
    Set Test Variable    ${temporal_entity_representation_id}
    ${response}=    Create Or Update Temporal Representation Of Entity Selecting Content Type
    ...    temporal_entity_representation_id=${temporal_entity_representation_id}
    ...    filename=${filename}
    ...    content_type=${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}

Delete Temporal Entity
    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
