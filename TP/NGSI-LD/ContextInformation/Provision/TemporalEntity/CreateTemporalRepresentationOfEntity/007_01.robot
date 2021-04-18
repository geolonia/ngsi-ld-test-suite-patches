*** Settings ***
Documentation     Check that you can create a temporal representation of an entity
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Test Template     Create Temporal Entity

*** Variable ***
${vehicle_id_prefix}=    urn:ngsi-ld:Vehicle:

*** Test Cases ***    FILENAME                                                         CONTENT_TYPE
007_01_01_Create a temporal representation of an entity
                      vehicle-temporal-representation-sample.jsonld                    application/ld+json

007_01_02_Create a temporal entity with no context
                      vehicle-temporal-representation-without-context-sample.jsonld    application/json

*** Keywords ***
Create Temporal Entity
    [Arguments]    ${filename}    ${content_type}
    [Documentation]    Check that you can create a temporal representation of an entity
    [Tags]    te-create    5_6_11
    ${temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    ${response}=    Create Or Update Temporal Representation Of Entity Selecting Content Type    ${temporal_entity_representation_id}    ${filename}    ${content_type}
    Check Response Status Code    201    ${response['status']}
    ${created_temporal_entity}=    Load Test Sample    temporalEntities/${filename}    ${temporal_entity_representation_id}
    Retrieve Temporal Representation Of Entity    ${temporal_entity_representation_id}
    ${ignored_attributes}=    Create List    instanceId    @context
    Check Created Resource Set To    ${created_temporal_entity}    ${ignored_attributes}
    [Teardown]    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
