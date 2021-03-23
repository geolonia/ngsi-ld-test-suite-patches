*** Settings ***
Documentation   Check that an error is raised if you delete a temporal enitity with not found 
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${filename}=  vehicle-temporal-representation-sample.jsonld    
${fragment_filename}=  vehicle-temporal-representation-fragment.jsonld 
${status_code}=  404

*** Test Cases ***
Add Attribute To Temporal Entity
    [Documentation]  Check that an error is raised if you delete a temporal enitity with not found
    [Tags]  tea-append

    ${temporal_entity_representation_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${response}=  Create Or Update Temporal Representation Of Entity Selecting Content Type  ${temporal_entity_representation_id}    ${filename}     ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${not_found_temporal_entity_representation_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${response}=  Append Attribute To Temporal Entity  ${not_found_temporal_entity_representation_id}    ${fragment_filename}     ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code   ${status_code}    ${response['status']}

    [Teardown]    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}