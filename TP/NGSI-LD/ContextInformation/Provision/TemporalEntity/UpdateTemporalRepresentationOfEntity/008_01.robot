*** Settings ***
Documentation       Check that you can update a temporal representation of an entity with simple temporal properties

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource


*** Variables ***
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:
${filename}=                vehicle-create-temporal-representation-sample.jsonld
${update_filename}=         vehicle-temporal-representation-update-sample.jsonld
${expectation_filename}=    vehicle-temporal-representation-update-expectation.jsonld


*** Test Cases ***
008_01_Update a temporal representation of an entity with simple temporal properties
    [Documentation]    Check that you can update a temporal representation of an entity with simple temporal properties
    [Tags]    te-update    5_6_11
    ${temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    ${response}=    Create Or Update Temporal Representation Of Entity Selecting Content Type
    ...    ${temporal_entity_representation_id}
    ...    ${filename}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Or Update Temporal Representation Of Entity Selecting Content Type
    ...    ${temporal_entity_representation_id}
    ...    ${update_filename}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    204    ${response.status_code}
    ${temporal_entity_expectation_payload}=    Load Test Sample
    ...    temporalEntities/expectations/${expectation_filename}
    ...    ${temporal_entity_representation_id}
    ${response}=    Retrieve Temporal Representation Of Entity
    ...    ${temporal_entity_representation_id}
    ...    context=${ngsild_test_suite_context}
    ...    accept=${CONTENT_TYPE_LD_JSON}
    ${ignored_attributes}=    Create List    instanceId    @context
    Check Updated Resource Set To
    ...    ${temporal_entity_expectation_payload}
    ...    ${response.json()}
    ...    ${ignored_attributes}
    [Teardown]    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
