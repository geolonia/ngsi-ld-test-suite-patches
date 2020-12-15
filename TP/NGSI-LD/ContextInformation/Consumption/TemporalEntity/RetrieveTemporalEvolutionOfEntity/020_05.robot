*** Settings ***
Documentation   Check that you can retrieve the temporal evolution of the last N instances of entity attributes
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Suite Setup      Setup Initial Entities
Suite Teardown      Delete Initial Entities
Test Template  Retrieve the temporal evolution of the last N instances of entity attributes

*** Variable ***
${vehicule_id_prefix}=  urn:ngsi-ld:Vehicle:
${vehicle_payload_file}=  vehicule-temporal-representation-multiple-instances-sample.jsonld

*** Test Cases ***          LASTN     VEHICLE_EXPECTATION_FILE
Retrieve Some Instances     ${10}        vehicle-temporal-representation-020-05-01-expectation.jsonld
Retrieve All Instances      ${20}        vehicle-temporal-representation-020-05-02-expectation.jsonld

*** Keywords ***
Retrieve the temporal evolution of the last N instances of entity attributes
    [Arguments]  ${lastN}     ${vehicle_expectation_file}
    [Documentation]  Check that you can retrieve the temporal evolution of the last N instances of entity attributes
    [Tags]  mandatory

    Retrieve Temporal Representation Of Entity   ${temporal_entity_representation_id}   lastN=${lastN}  context=${ngsild_test_suite_context}
    
    Check Response Status Code Set To  200
    Check Response Body Containing EntityTemporal element       ${vehicle_expectation_file}    ${temporal_entity_representation_id}

Setup Initial Entities
    ${temporal_entity_representation_id}=     Generate Random Entity Id    ${vehicule_id_prefix}
    Create Temporal Representation Of Entity  ${vehicle_payload_file}     ${temporal_entity_representation_id}
    Set Suite Variable  ${temporal_entity_representation_id}

Delete Initial Entities
    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
