*** Settings ***
Documentation   Check that you can retrieve the temporal evolution of an entity with the simplified temporal representation
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Suite Setup      Setup Initial Entities

*** Variable ***
${vehicule_id_prefix}=  urn:ngsi-ld:Vehicle:
${vehicle_payload_file}=  vehicule-temporal-representation-sample.jsonld
${vehicle_expectation_file}=  vehicle-simplified-temporal-representation-expectation.jsonld

*** Test Case ***
Retrieve the temporal evolution of an entity with the simplified temporal representation
    [Documentation]  Check that you can retrieve the temporal evolution of an entity with the simplified temporal representation
    [Tags]  mandatory

    @{options}=  Create List   temporalValues
    Retrieve Temporal Representation Of Entity   ${temporal_entity_representation_id}   options=${options}    context=${ngsild_test_suite_context}

    Check Response Status Code Set To  200
    Check Response Body Containing EntityTemporal element       ${vehicle_expectation_file}    ${temporal_entity_representation_id}

    #TODO Call Delete Temporal Representation Of Entity

*** Keywords ***
Setup Initial Entities
    ${temporal_entity_representation_id}=     Generate Random Entity Id    ${vehicule_id_prefix}
    Create Temporal Representation Of Entity  ${vehicle_payload_file}     ${temporal_entity_representation_id}
    Set Suite Variable  ${temporal_entity_representation_id}
