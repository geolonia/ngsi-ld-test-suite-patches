*** Settings ***
Documentation   Check that you can add a simple temporal attribute to a temporal representation of an entity
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${filename}=  vehicle-temporal-representation-sample.jsonld
${fragment_filename}=  vehicle-temporal-representation-fragment.jsonld
${expectation_filename}=  vehicle-temporal-representation-added-attribute-expectation.jsonld

*** Test Cases ***
014_01_02_Add an attribute to a temporal entity with simple temporal properties
    [Documentation]  Check that you can add a simple temporal attribute to a temporal representation of an entity
    [Tags]  mandatory

    ${temporal_entity_representation_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${response}=  Create Or Update Temporal Representation Of Entity Selecting Content Type  ${temporal_entity_representation_id}    ${filename}     ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=  Append Attribute To Temporal Entity  ${temporal_entity_representation_id}    ${fragment_filename}     ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  204    ${response['status']}

    ${temporal_entity_expectation_payload}=    Load Test Sample   temporalEntities/expectations/${expectation_filename}    ${temporal_entity_representation_id}
    Retrieve Temporal Representation Of Entity   ${temporal_entity_representation_id}    context=${ngsild_test_suite_context}   accept=${CONTENT_TYPE_LD_JSON}
    ${ignored_attributes}=  Create List    ${status_regex_expr}    instanceId
    Check Updated Resource Set To     ${temporal_entity_expectation_payload}

    [Teardown]    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}