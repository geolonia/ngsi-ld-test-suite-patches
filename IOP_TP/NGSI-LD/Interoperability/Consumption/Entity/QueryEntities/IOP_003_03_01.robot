*** Settings ***
Documentation       Four brokers are set up b1, b2, b3 and b4. b1 has three registrations, one auxiliary for the entities in b2, one inclusive for the entities in b3 and one inclusive for the entity in b4.
...                 Check that the OffStreetParking:1 entity in b1 has the same name and location attributes as the ones in b3. Check that the entity OffStreetParking:1 in b1 has the same availableSpotsNumber and totalSpotsNumber attributes as the one in b4. Check that the OffStreetParking:2 entity is the same as the one in b2.

Resource            ${EXECDIR}/resources/IOPUtils/InteroperabilityUtils.resource

Test Teardown       Delete Entities and Delete Registrations
Test Template       Run Interoperability Scenario


*** Variables ***
${offstreet_no_location_payload_filename}               interoperability/offStreetParking2-without-location.jsonld
${first_offstreet_no_location_payload_filename}         interoperability/offStreetParking1-without-location.jsonld
${first_full_offstreet_payload_filename}                interoperability/full-version-of-OffStreetParking1.jsonld
${second_full_offstreet_payload_filename}               interoperability/full-version-of-OffStreetParking2.jsonld
${first_inclusive_registration_payload_file_path}       csourceRegistrations/interoperability/context-source-registration-inclusive-1.jsonld
${second_inclusive_registration_payload_file_path}      csourceRegistrations/interoperability/context-source-registration-inclusive-2.jsonld
${auxiliary_registration_payload_file_path}             csourceRegistrations/interoperability/context-source-registration-auxiliary-1.jsonld
${b1_url}                                               ${EMPTY}
${b2_url}                                               ${EMPTY}
${b3_url}                                               ${EMPTY}
${b4_url}                                               ${EMPTY}


*** Test Cases ***
IOP_003_03_01_01 Query Entities Of Type OffstreetParking Via GET With Default Context
    [Tags]
    ...    since_v1.6.1
    ...    iop
    ...    cnf_03
    ...    4_3_3
    ...    additive-inclusive
    ...    additive-auxiliary
    ...    4_3_6
    ...    5_7_2
    ...    6_4_3_1
    ...    default-context
    [Setup]    Setup Initial Context Source Registrations    ${core_context}
    ${core_context}
IOP_003_03_01_02 Query Entities Of Type OffstreetParking Via GET With User Context
    [Tags]
    ...    since_v1.6.1
    ...    iop
    ...    cnf_03
    ...    4_3_3
    ...    additive-inclusive
    ...    additive-auxiliary
    ...    4_3_6
    ...    5_7_2
    ...    6_4_3_1
    ...    user-context
    [Setup]    Setup Initial Context Source Registrations    ${ngsild_test_suite_context}
    ${ngsild_test_suite_context}


*** Keywords ***
Run Interoperability Scenario
    [Arguments]    ${context}

    # Client sends an HTTP GET request to b1 to retrieve Entities with type OffstreetParking
    ${response_b1}=    Query Entities
    ...    entity_types=OffStreetParking
    ...    broker_url=${b1_url}
    ...    context=${context}

    # Agent checks that a success response has been returned with ${first_full_offstreet_payload_filename} and ${offstreet_no_location_payload_filename}
    Check Response Status Code    200    ${response_b1.status_code}
    ${expected_b1_ids}=    Create List    ${first_entity_id}    ${second_entity_id}
    Check Response Body Containing Entities URIS set to    ${expected_b1_ids}    ${response_b1.json()}
    ${first_entity_b1}=    Get Value From JSON    ${response_b1.json()}    $[?(@.id=='${first_entity_id}')]
    ${second_entity_b1}=    Get Value From JSON    ${response_b1.json()}    $[?(@.id=='${second_entity_id}')]

    # Client sends an HTTP GET request to b2 to retrieve Entities with type OffstreetParking
    ${response_b2}=    Query Entities
    ...    entity_types=OffStreetParking
    ...    broker_url=${b2_url}
    ...    context=${context}
    Check Response Status Code    200    ${response_b2.status_code}
    ${expected_b2_ids}=    Create List    ${second_entity_id}
    Check Response Body Containing Entities URIS set to    ${expected_b2_ids}    ${response_b2.json()}
    ${second_entity_b2}=    Get Value From JSON    ${response_b2.json()}    $[?(@.id=='${second_entity_id}')]

    # Client sends an HTTP GET request to b3 to retrieve Entities with type OffstreetParking
    ${response_b3}=    Query Entities
    ...    entity_types=OffStreetParking
    ...    broker_url=${b3_url}
    ...    context=${context}
    Check Response Status Code    200    ${response_b3.status_code}
    ${expected_b3_ids}=    Create List    ${first_entity_id}
    Check Response Body Containing Entities URIS set to    ${expected_b3_ids}    ${response_b3.json()}
    ${first_entity_b3}=    Get Value From JSON    ${response_b3.json()}    $[?(@.id=='${first_entity_id}')]

    # Client sends an HTTP GET request to b4 to retrieve Entities with type OffstreetParking
    ${response_b4}=    Query Entities
    ...    entity_types=OffStreetParking
    ...    broker_url=${b4_url}
    ...    context=${context}
    Check Response Status Code    200    ${response_b4.status_code}
    ${expected_b4_ids}=    Create List    ${first_entity_id}
    Check Response Body Containing Entities URIS set to    ${expected_b4_ids}    ${response_b4.json()}
    ${first_entity_b4}=    Get Value From JSON    ${response_b4.json()}    $[?(@.id=='${first_entity_id}')]

    ${expected_second_b2}=    Load Entity    ${offstreet_no_location_payload_filename}    ${second_entity_id}
    Check Resource Set To    ${expected_second_b2}    ${second_entity_b2}[0]
    ${expected_first_b3}=    Load Entity    ${first_full_offstreet_payload_filename}    ${first_entity_id}
    Check Resource Set To    ${expected_first_b3}    ${first_entity_b3}[0]
    ${expected_first_b4}=    Load Entity    ${first_offstreet_no_location_payload_filename}    ${first_entity_id}
    Check Resource Set To    ${expected_first_b4}    ${first_entity_b4}[0]

    # Agent checks that OffstreetParking:1 combines b3 and b4 and OffstreetParking:2 matches b2
    ${expected_first_b1}=    Load Entity    ${first_full_offstreet_payload_filename}    ${first_entity_id}
    Set To Dictionary
    ...    ${expected_first_b1}
    ...    availableSpotsNumber=${first_entity_b4}[0][availableSpotsNumber]
    ...    totalSpotsNumber=${first_entity_b4}[0][totalSpotsNumber]
    ...    name=${first_entity_b3}[0][name]
    ...    location=${first_entity_b3}[0][location]
    Check Resource Set To    ${expected_first_b1}    ${first_entity_b1}[0]
    Check Resource Set To    ${second_entity_b2}[0]    ${second_entity_b1}[0]

Setup Initial Context Source Registrations
    [Arguments]    ${context}
    Set Test Variable    ${first_entity_id}    urn:ngsi-ld:OffStreetParking:1
    Set Test Variable    ${second_entity_id}    urn:ngsi-ld:OffStreetParking:2

    ${response}=    Create Entity
    ...    ${offstreet_no_location_payload_filename}
    ...    ${second_entity_id}
    ...    broker_url=${b2_url}
    ...    context=${context}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity
    ...    ${first_full_offstreet_payload_filename}
    ...    ${first_entity_id}
    ...    broker_url=${b3_url}
    ...    context=${context}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity
    ...    ${first_offstreet_no_location_payload_filename}
    ...    ${first_entity_id}
    ...    broker_url=${b4_url}
    ...    context=${context}
    Check Response Status Code    201    ${response.status_code}

    @{first_set}=    Create List
    ...    ${EMPTY}
    ...    ${auxiliary_registration_payload_file_path}
    ...    auxiliary
    ...    ${b2_url}
    ...    ${b1_url}

    @{second_set}=    Create List
    ...    ${EMPTY}
    ...    ${first_inclusive_registration_payload_file_path}
    ...    inclusive
    ...    ${b3_url}
    ...    ${b1_url}

    @{third_set}=    Create List
    ...    ${EMPTY}
    ...    ${second_inclusive_registration_payload_file_path}
    ...    inclusive
    ...    ${b4_url}
    ...    ${b1_url}

    @{third_configuration}=    Create List    ${first_set}    ${second_set}    ${third_set}
    Compose IOP Configuration    ${third_configuration}    ld_context=${context}

Delete Entities And Delete Registrations
    @{broker_count}=    Create List    ${b1_url}    ${b2_url}    ${b3_url}    ${b4_url}
    @{entities_to_delete}=    Create List    ${first_entity_id}    ${second_entity_id}
    Delete Registrations And Entities    ${broker_count}    ${entities_to_delete}
