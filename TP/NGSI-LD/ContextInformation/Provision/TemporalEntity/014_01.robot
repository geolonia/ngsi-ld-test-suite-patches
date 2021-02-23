*** Settings ***
Documentation   Check that you can add a simple temporal attribute to a temporal representation of an entity
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${filename}=  vehicle-temporal-representation-sample.jsonld
${fragment_filename}=  vehicle-temporal-representation-fragment-sample.jsonld

*** Test Cases ***
014_01_02_Add an attribute to a temporal entity with simple temporal properties
    [Documentation]  Check that you can add a simple temporal attribute to a temporal representation of an entity
    [Tags]  mandatory

    ${temporal_entity_representation_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${response}=  Create Or Update Temporal Representation Of Entity Selecting Content Type  ${temporal_entity_representation_id}    ${filename}     ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=  Append Attribute To Temporal Entity  ${temporal_entity_representation_id}    ${fragment_filename}     ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  204    ${response['status']}

    [Teardown]    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}