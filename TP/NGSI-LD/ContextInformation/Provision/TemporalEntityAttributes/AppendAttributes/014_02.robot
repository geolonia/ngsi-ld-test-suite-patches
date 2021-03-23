*** Settings ***
Documentation   Check that an error is raised if you delete a temporal enitity with empty/invalid content
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${filename}=  vehicle-temporal-representation-sample.jsonld
${fragment_filename}=  vehicle-temporal-representation-fragment.jsonld  
${status_code}=  400

*** Test Cases ***
014_02_01_Add an attribute to a temporal representation of an entity with invalid content
  Add an Attribute To a Temporal Entity  vehicle-temporal-representation-invalid-json-fragment.jsonld

014_02_02_Add an attribute to a temporal representation of an entity with empty content
  Add an Attribute To a Temporal Entity  vehicle-temporal-representation-empty-json-fragment.jsonld

014_02_03_Add an attribute to a temporal representation of an entity with an empty entity id
  Fail To Add Attribute To Temporal Entity  ${EMPTY}

014_02_04_Add an attribute to a temporal representation of an entity with an invalid entity id
  Fail To Add Attribute To Temporal Entity  thisIsAninvalidId

*** Keywords ***
Add an Attribute To a Temporal Entity
    [Arguments]  ${update_filename}
    [Documentation]  Check that an error is raised if you delete a temporal enitity with empty/invalid content
    [Tags]  tea-append

    ${temporal_entity_representation_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${response}=  Create Or Update Temporal Representation Of Entity Selecting Content Type  ${temporal_entity_representation_id}    ${filename}     ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=  Append Attribute To Temporal Entity Using Session  ${temporal_entity_representation_id}    ${update_filename}     ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code   <Response [400]>    ${response['status']}

    [Teardown]    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}

Fail To Add Attribute To Temporal Entity
    [Arguments]  ${id}
    [Documentation]  Check that an error is raised if you delete a temporal enitity with a non existing/invalid EnityId
    [Tags]  tea-append

    ${temporal_entity_representation_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${response}=  Create Or Update Temporal Representation Of Entity Selecting Content Type  ${temporal_entity_representation_id}    ${filename}     ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=  Append Attribute To Temporal Entity  ${id}    ${fragment_filename}     ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code   ${status_code}    ${response['status']}

    [Teardown]    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}