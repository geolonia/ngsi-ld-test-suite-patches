*** Settings ***
Documentation       Check that you can delete a temporal representation of an entity with simple temporal properties

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource


*** Variables ***
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:
${filename}=                vehicle-temporal-representation-sample.jsonld


*** Test Cases ***
Delete a temporal representation of an entity with simple temporal properties
    [Documentation]    Check that you can delete a temporal representation of an entity with simple temporal properties
    [Tags]    te-delete    5_6_16
    ${temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    ${response}=    Create Or Update Temporal Representation Of Entity Selecting Content Type
    ...    ${temporal_entity_representation_id}
    ...    ${filename}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Delete Temporal Representation Of Entity With Returning Response
    ...    ${temporal_entity_representation_id}
    Check Response Status Code    204    ${response.status_code}
    ${response}=    Retrieve Temporal Representation Of Entity
    ...    ${temporal_entity_representation_id}
    ...    context=${ngsild_test_suite_context}
    Check SUT Not Containing Resource
