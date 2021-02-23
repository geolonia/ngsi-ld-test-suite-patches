*** Settings ***
Documentation   Check that you can update a temporal representation of an entity with simple temporal properties
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${filename}=  vehicle-temporal-representation-sample.jsonld
${update_filename}=  vehicle-temporal-representation-update-sample.jsonld

*** Test Cases ***                                                                                           
008_01_Update a temporal representation of an entity with simple temporal properties                           
    [Documentation]  Check that you can update a temporal representation of an entity with simple temporal properties
    [Tags]  mandatory

    ${temporal_entity_representation_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${response}=  Create Or Update Temporal Representation Of Entity Selecting Content Type  ${temporal_entity_representation_id}    ${filename}     ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=  Create Or Update Temporal Representation Of Entity Selecting Content Type  ${temporal_entity_representation_id}    ${update_filename}     ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  204    ${response['status']}


    [Teardown]    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}