*** Settings ***
Documentation     Check that you can partially update an attribute instance of a temporal representation of an entity
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${vehicle_id_prefix}=    urn:ngsi-ld:Vehicle:
${filename}=      vehicle-temporal-representation-sample.jsonld
${fragment_filename}=    vehicle-temporal-instanceid-update-fragment.jsonld
${expectation_filename}=    vehicle-temporal-representation-update-expectation.jsonld
${attributeId}=    speed

*** Test Cases ***
016_01_Partially update an attribute instance of a temporal representation of an entity
    [Documentation]    Check that you can partially update an attribute instance of a temporal representation of an entity
    [Tags]    tea-partial-update    5_6_14
    ${temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    Set Suite Variable    ${temporal_entity_representation_id}
    ${response}=    Create Or Update Temporal Representation Of Entity Selecting Content Type    ${temporal_entity_representation_id}    ${filename}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response['status']}
    ${response}=    Get Temporal Representation Of Entity    ${temporal_entity_representation_id}    ${CONTENT_TYPE_LD_JSON}    sysAttrs    ${ngsild_test_suite_context}
    ${createdAt_before_update}=    Set Variable    ${response['body']['speed'][0]['createdAt']}
    ${modifiedAt_before_update}=    Set Variable    ${response['body']['speed'][0]['modifiedAt']}
    ${instanceId}=    Set Variable    ${response['body']['speed'][0]['instanceId']}
    ${response}=    Partial Update Attribute From Temporal Entity    ${temporal_entity_representation_id}    ${attributeId}    ${instanceId}    ${fragment_filename}    ${CONTENT_TYPE_JSON}    ${ngsild_test_suite_context}
    Check Response Status Code    204    ${response['status']}
    ${response}=    Get Temporal Representation Of Entity    ${temporal_entity_representation_id}    ${CONTENT_TYPE_LD_JSON}    sysAttrs
    ${createdAt_after_update}=    Set Variable    ${response['body']['speed'][0]['createdAt']}
    ${modifiedAt_after_update}=    Set Variable    ${response['body']['speed'][0]['modifiedAt']}
    Should Be Equal As Strings    ${createdAt_before_update}    ${modifiedAt_before_update}
    Should Be Equal As Strings    ${createdAt_before_update}    ${createdAt_after_update}
    ${modifiedAt_before_update_date}=    Convert Date    ${modifiedAt_before_update}    epoch
    ${modifiedAt_after_update_date}=    Convert Date    ${modifiedAt_after_update}    epoch
    Should Be True    ${modifiedAt_before_update_date}<${modifiedAt_after_update_date}
    ${temporal_entity_expectation_payload}=    Load Test Sample    temporalEntities/expectations/${expectation_filename}    ${temporal_entity_representation_id}
    Retrieve Temporal Representation Of Entity    ${temporal_entity_representation_id}    context=${ngsild_test_suite_context}    accept=${CONTENT_TYPE_LD_JSON}
    ${ignored_attributes}=    Create List    instanceId    @context
    Check Updated Resource Set To    ${temporal_entity_expectation_payload}    ${ignored_attributes}
    [Teardown]    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
