*** Settings ***
Documentation       Three brokers are set up b1, b2 and b3. b1 has two registrations, one inclusive for the entities in b2 and one exclusive for the entity in b3.
...                 Check that the OffStreetParking:1 entity returned from b2 matches the full OffStreetParking:1 entity.

Resource            ${EXECDIR}/resources/IOPUtils/InteroperabilityUtils.resource

Test Teardown       Delete Entities and Delete Registrations
Test Template       Run Interoperability Scenario


*** Variables ***
${first_entity_payload_filename}                interoperability/full-version-of-OffStreetParking1.jsonld
${second_entity_payload_filename}               interoperability/full-version-of-OffStreetParking2.jsonld
${inclusive_registration_payload_file_path}     csourceRegistrations/interoperability/context-source-registration-inclusive-2.jsonld
${exclusive_registration_payload_file_path}     csourceRegistrations/interoperability/context-source-registration-exclusive-2.jsonld
${b1_url}                                       ${EMPTY}
${b2_url}                                       ${EMPTY}
${b3_url}                                       ${EMPTY}


*** Test Cases ***
IOP_002_01_01_01 Retrieve OffStreetParking:1 With Default Context
    [Tags]
    ...    since_v1.6.1
    ...    iop
    ...    cnf_01
    ...    4_3_3
    ...    additive-inclusive
    ...    proxy-exclusive
    ...    4_3_6
    ...    5_7_1
    ...    default-context
    [Setup]    Setup Initial Context Source Registrations    ${core_context}
    ${core_context}
IOP_002_01_01_02 Retrieve OffStreetParking:1 With User Context
    [Tags]
    ...    since_v1.6.1
    ...    iop
    ...    cnf_01
    ...    4_3_3
    ...    additive-inclusive
    ...    proxy-exclusive
    ...    4_3_6
    ...    5_7_1
    ...    user-context
    [Setup]    Setup Initial Context Source Registrations    ${ngsild_test_suite_context}
    ${ngsild_test_suite_context}


*** Keywords ***
Run Interoperability Scenario
    [Arguments]    ${context}

    # Client sends an HTTP GET request to b1 to retrieve the OffStreetParking:1
    ${response_b1}=    Retrieve Entity
    ...    ${first_entity_id}
    ...    context=${context}
    ...    broker_url=${b1_url}
    ...    type=OffStreetParking

    # Agent checks that a success response has been returned and that only availableSpotsNumber and totalSpotsNumber of OffStreetParking:1 were returned
    Check Response Status Code    200    ${response_b1.status_code}

    # Client sends an HTTP GET request to b2 to retrieve the OffStreetParking:1
    ${response_b2}=    Retrieve Entity
    ...    ${first_entity_id}
    ...    context=${context}
    ...    broker_url=${b2_url}
    ...    type=OffStreetParking
    Check Response Status Code    200    ${response_b2.status_code}

    # Agent checks that the Entity returned in step (3) matches ${first_entity_payload_filename}
    ${expected_b2}=    Load Entity    ${first_entity_payload_filename}    ${first_entity_id}
    Check Resource Set To    ${expected_b2}    ${response_b2.json()}

    ${expected_b1}=    Load Entity    ${first_entity_payload_filename}    ${first_entity_id}
    Keep In Dictionary    ${expected_b1}    id    type    availableSpotsNumber    totalSpotsNumber
    Set To Dictionary
    ...    ${expected_b1}
    ...    availableSpotsNumber=${response_b2.json()}[availableSpotsNumber]
    ...    totalSpotsNumber=${response_b2.json()}[totalSpotsNumber]
    Check Resource Set To    ${expected_b1}    ${response_b1.json()}

Setup Initial Context Source Registrations
    [Arguments]    ${context}
    Set Test Variable    ${first_entity_id}    urn:ngsi-ld:OffStreetParking:1
    Set Test Variable    ${second_entity_id}    urn:ngsi-ld:OffStreetParking:2

    ${response}=    Create Entity
    ...    ${first_entity_payload_filename}
    ...    ${first_entity_id}
    ...    broker_url=${b2_url}
    ...    context=${context}
    Check Response Status Code    201    ${response.status_code}

    ${response}=    Create Entity
    ...    ${second_entity_payload_filename}
    ...    ${second_entity_id}
    ...    broker_url=${b2_url}
    ...    context=${context}
    Check Response Status Code    201    ${response.status_code}

    ${response}=    Create Entity
    ...    ${second_entity_payload_filename}
    ...    ${second_entity_id}
    ...    broker_url=${b3_url}
    ...    context=${context}
    Check Response Status Code    201    ${response.status_code}

    @{first_set}=    Create List
    ...    ${EMPTY}
    ...    ${inclusive_registration_payload_file_path}
    ...    inclusive
    ...    ${b2_url}
    ...    ${b1_url}

    @{second_set}=    Create List
    ...    ${EMPTY}
    ...    ${exclusive_registration_payload_file_path}
    ...    exclusive
    ...    ${b3_url}
    ...    ${b1_url}

    @{first_configuration}=    Create List    ${first_set}    ${second_set}
    Compose IOP Configuration    ${first_configuration}    ld_context=${context}

Delete Entities And Delete Registrations
    @{broker_count}=    Create List    ${b1_url}    ${b2_url}    ${b3_url}
    @{entities_to_delete}=    Create List    ${first_entity_id}    ${second_entity_id}
    Delete Registrations And Entities    ${broker_count}    ${entities_to_delete}
