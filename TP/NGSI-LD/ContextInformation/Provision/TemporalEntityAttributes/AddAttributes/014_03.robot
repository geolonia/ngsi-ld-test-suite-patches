*** Settings ***
Documentation       Check that an error is raised if one adds an attribute to a non-existent entity

Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Teardown      Delete Temporal Entity


*** Variables ***
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:
${filename}=                vehicle-temporal-representation-sample.jsonld
${fragment_filename}=       vehicle-temporal-representation-fragment.jsonld
${status_code}=             404


*** Test Cases ***
014_03_01 Add Attribute To Temporal Entity
    [Documentation]    Check that an error is raised if one adds an attribute to a non-existent entity
    [Tags]    tea-append    5_6_12
    ${temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    Set Suite Variable    ${temporal_entity_representation_id}
    ${create_response}=    Create Or Update Temporal Representation Of Entity Selecting Content Type
    ...    temporal_entity_representation_id=${temporal_entity_representation_id}
    ...    filename=${filename}
    ...    content_type=${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${create_response.status_code}
    ${not_found_temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    ${response}=    Append Attribute To Temporal Entity
    ...    ${not_found_temporal_entity_representation_id}
    ...    ${fragment_filename}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    ${status_code}    ${response.status_code}


*** Keywords ***
Delete Temporal Entity
    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
