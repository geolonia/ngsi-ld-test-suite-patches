*** Settings ***
Documentation       Check that you can modify an attribute instance in temporal representation of an entity

Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationProvision/ApiUtils.resource
# Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Teardown      Delete Intitial Temporal Representation Of Entity


*** Variables ***
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:
${filename}=                vehicle-temporal-representation-sample.jsonld
${fragment_filename}=       vehicle-temporal-modify-attribute-instance-fragment.jsonld
${expectation_filename}=    vehicle-temporal-representation-modify-attribute-instance-expectation.jsonld
${attributeId}=             speed


*** Test Cases ***
016_01_Modify attribute instance in temporal representation of an entity
    [Documentation]    Check that you can partially update an attribute instance of a temporal representation of an entity
    [Tags]    tea-partial-update    5_6_14
    ${temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    Set Suite Variable    ${temporal_entity_representation_id}

    ${response}=    Create Or Update Temporal Representation Of Entity Selecting Content Type
    ...    ${temporal_entity_representation_id}
    ...    ${filename}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}

    ${response}=    Retrieve Temporal Representation Of Entity
    ...    ${temporal_entity_representation_id}
    ...    context=${ngsild_test_suite_context}
    ...    accept=${CONTENT_TYPE_LD_JSON}
    ${instanceId_before_update}=    Set Variable    ${response.json()['speed'][0]['instanceId']}

    ${response}=    Modify Attribute Instance From Temporal Entity
    ...    ${temporal_entity_representation_id}
    ...    ${attributeId}
    ...    ${instanceId_before_update}
    ...    ${fragment_filename}
    ...    ${CONTENT_TYPE_JSON}
    ...    ${ngsild_test_suite_context}
    Check Response Status Code    204    ${response.status_code}

    ${temporal_entity_expectation_payload}=    Load Test Sample
    ...    temporalEntities/expectations/${expectation_filename}
    ...    ${temporal_entity_representation_id}
    ${response}=    Retrieve Temporal Representation Of Entity
    ...    ${temporal_entity_representation_id}
    ...    context=${ngsild_test_suite_context}
    ...    accept=${CONTENT_TYPE_LD_JSON}
    ${instanceId_after_update}=    Set Variable    ${response.json()['speed'][0]['instanceId']}

    Should Be Equal As Strings    ${instanceId_before_update}    ${instanceId_after_update}

    ${temporal_entity_expectation_payload}=    Load Test Sample
    ...    temporalEntities/expectations/${expectation_filename}
    ...    ${temporal_entity_representation_id}
    ${ignored_attributes}=    Create List    instanceId    @context    modifiedAt
    Check Updated Resource Set To
    ...    ${temporal_entity_expectation_payload}
    ...    ${response.json()}
    ...    ${ignored_attributes}


*** Keywords ***
Delete Intitial Temporal Representation Of Entity
    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
