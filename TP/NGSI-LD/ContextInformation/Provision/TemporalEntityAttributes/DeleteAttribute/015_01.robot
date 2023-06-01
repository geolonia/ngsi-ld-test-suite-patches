*** Settings ***
Documentation       Check that you can delete an attribute of a temporal representation of an entity with simple temporal properties

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Template       Delete Attribute From A Temporal Entity


*** Variables ***
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:
${filename}=                vehicle-temporal-representation-sample.jsonld
${status_code}=             204
${attribute_id}=            fuelLevel


*** Test Cases ***    DELETEALL    DATASETID    EXPECTATION_FILE
015_01_01_Delete an attribute from a temporal representation of an entity without deleteAll/datasetId
    false    ${EMPTY}    vehicle-temporal-representation-delete-fuelLevel-expectation.jsonld
015_01_02_Delete an attribute from a temporal representation of an entity with datasetId
    false    urn:ngsi-ld:Vehicle:12345-fuel    vehicle-temporal-representation-delete-fuelLevel-datasetid-expectation.jsonld
015_01_03_Delete an attribute from a temporal representation of an entity with deleteAll
    true    ${EMPTY}    vehicle-temporal-representation-deleteall-fuelLevel-expectation.jsonld


*** Keywords ***
Delete Attribute From A Temporal Entity
    [Documentation]    Check that you can delete an attribute of a temporal representation of an entity with simple temporal properties
    [Tags]    tea-delete    5_6_13
    [Arguments]    ${deleteAll}    ${datasetId}    ${expectation_filename}
    ${temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    ${response}=    Create Or Update Temporal Representation Of Entity Selecting Content Type
    ...    ${temporal_entity_representation_id}
    ...    ${filename}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Delete Attribute From Temporal Entity
    ...    ${temporal_entity_representation_id}
    ...    ${attribute_id}
    ...    ${CONTENT_TYPE_JSON}
    ...    ${datasetId}
    ...    ${deleteAll}
    ...    ${ngsild_test_suite_context}
    Check Response Status Code    ${status_code}    ${response.status_code}
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
