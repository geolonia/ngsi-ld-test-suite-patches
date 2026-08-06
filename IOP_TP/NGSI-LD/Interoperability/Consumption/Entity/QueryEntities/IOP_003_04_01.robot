*** Settings ***
Documentation       Five brokers are set up b1, b2, b3, b4 and b5. b1 has two registrations, one auxiliary for the entity in b2, one inclusive for the entity in b3. b2 has two registrations, one redirect for the entity in b4 and one redirect for the entity in b5. b3 has two exclusive registrations to b5.
...                 Check that the OffStreetParking:1 entity has the same location attribute as the one in b5. Check that the OffStreetParking:2 entity in b1 has the same availableSpotsNumber and totalSpotsNumber as the ones found in b4. Check that the OffStreetParking:2 entity in b1 has the same location attribute as the one in b5.

Resource            ${EXECDIR}/resources/IOPUtils/InteroperabilityUtils.resource

Test Teardown       Delete Entities and Delete Registrations
Test Template       Run Interoperability Scenario


*** Variables ***
${first_parking_location_name_payload_filename}         interoperability/offStreetParking1-with-location-and-name-only.jsonld
${second_parking_location_name_payload_filename}        interoperability/offStreetParking2-with-location-and-name-only.jsonld
${first_full_parking_payload_filename}                  interoperability/full-version-of-OffStreetParking1.jsonld
${second_full_parking_payload_filename}                 interoperability/full-version-of-OffStreetParking2.jsonld
${auxiliary_registration_payload_file_path}             csourceRegistrations/interoperability/context-source-registration-auxiliary-2.jsonld
${inclusive_registration_payload_file_path}             csourceRegistrations/interoperability/context-source-registration-inclusive-1.jsonld
${first_exclusive_registration_payload_file_path}       csourceRegistrations/interoperability/context-source-registration-exclusive-2.jsonld
${second_exclusive_registration_payload_file_path}      csourceRegistrations/interoperability/context-source-registration-exclusive-3.jsonld
${first_redirect_registration_payload_file_path}        csourceRegistrations/interoperability/context-source-registration-redirect-1.jsonld
${second_redirect_registration_payload_file_path}       csourceRegistrations/interoperability/context-source-registration-redirect-2.jsonld
${b1_url}                                               ${EMPTY}
${b2_url}                                               ${EMPTY}
${b3_url}                                               ${EMPTY}
${b4_url}                                               ${EMPTY}
${b5_url}                                               ${EMPTY}


*** Test Cases ***
IOP_003_04_01_01 Query Entities Of Type OffstreetParking Via GET With Default Context
    [Tags]
    ...    since_v1.6.1
    ...    iop
    ...    cnf_04
    ...    4_3_3
    ...    additive-inclusive
    ...    additive-auxiliary
    ...    proxy-exclusive
    ...    proxy-redirect
    ...    4_3_6
    ...    5_7_2
    ...    6_4_3_1
    ...    default-context
    [Setup]    Setup Initial Context Source Registrations    ${core_context}
    ${core_context}
IOP_003_04_01_02 Query Entities Of Type OffstreetParking Via GET With User Context
    [Tags]
    ...    since_v1.6.1
    ...    iop
    ...    cnf_04
    ...    4_3_3
    ...    additive-inclusive
    ...    additive-auxiliary
    ...    proxy-exclusive
    ...    proxy-redirect
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

    # Agent checks that a success response has been returned with OffstreetParking:1 containing "location" and OffstreetParking:2 containing "availableSpotsNumber", "totalSpotsNumber" and "location"
    Check Response Status Code    200    ${response_b1.status_code}
    ${expected_b1_ids}=    Create List    ${first_entity_id}    ${second_entity_id}
    Check Response Body Containing Entities URIS set to    ${expected_b1_ids}    ${response_b1.json()}
    ${first_entity_b1}=    Get Value From JSON    ${response_b1.json()}    $[?(@.id=='${first_entity_id}')]
    ${second_entity_b1}=    Get Value From JSON    ${response_b1.json()}    $[?(@.id=='${second_entity_id}')]

    # Client sends an HTTP GET request to b4 to retrieve Entities with type OffstreetParking
    ${response_b4}=    Query Entities
    ...    entity_types=OffStreetParking
    ...    broker_url=${b4_url}
    ...    context=${context}
    Check Response Status Code    200    ${response_b4.status_code}
    ${expected_b4_ids}=    Create List    ${first_entity_id}    ${second_entity_id}
    Check Response Body Containing Entities URIS set to    ${expected_b4_ids}    ${response_b4.json()}
    ${first_entity_b4}=    Get Value From JSON    ${response_b4.json()}    $[?(@.id=='${first_entity_id}')]
    ${second_entity_b4}=    Get Value From JSON    ${response_b4.json()}    $[?(@.id=='${second_entity_id}')]

    # Client sends an HTTP GET request to b5 to retrieve Entities with type OffstreetParking
    ${response_b5}=    Query Entities
    ...    entity_types=OffStreetParking
    ...    broker_url=${b5_url}
    ...    context=${context}
    Check Response Status Code    200    ${response_b5.status_code}
    ${expected_b5_ids}=    Create List    ${first_entity_id}    ${second_entity_id}
    Check Response Body Containing Entities URIS set to    ${expected_b5_ids}    ${response_b5.json()}
    ${first_entity_b5}=    Get Value From JSON    ${response_b5.json()}    $[?(@.id=='${first_entity_id}')]
    ${second_entity_b5}=    Get Value From JSON    ${response_b5.json()}    $[?(@.id=='${second_entity_id}')]

    ${expected_first_b4}=    Load Entity
    ...    ${first_parking_location_name_payload_filename}
    ...    ${first_entity_id}
    Check Resource Set To    ${expected_first_b4}    ${first_entity_b4}[0]
    ${expected_second_b4}=    Load Entity    ${second_full_parking_payload_filename}    ${second_entity_id}
    Check Resource Set To    ${expected_second_b4}    ${second_entity_b4}[0]
    ${expected_first_b5}=    Load Entity    ${first_full_parking_payload_filename}    ${first_entity_id}
    Check Resource Set To    ${expected_first_b5}    ${first_entity_b5}[0]
    ${expected_second_b5}=    Load Entity
    ...    ${second_parking_location_name_payload_filename}
    ...    ${second_entity_id}
    Check Resource Set To    ${expected_second_b5}    ${second_entity_b5}[0]

    # Agent checks that OffstreetParking:1 uses the location from b5 and OffstreetParking:2 combines b4 and b5
    ${expected_first_b1}=    Load Entity    ${first_full_parking_payload_filename}    ${first_entity_id}
    Keep In Dictionary    ${expected_first_b1}    id    type    location
    Set To Dictionary    ${expected_first_b1}    location=${first_entity_b5}[0][location]
    Check Resource Set To    ${expected_first_b1}    ${first_entity_b1}[0]

    ${expected_second_b1}=    Load Entity    ${second_full_parking_payload_filename}    ${second_entity_id}
    Keep In Dictionary    ${expected_second_b1}    id    type    availableSpotsNumber    totalSpotsNumber
    Set To Dictionary
    ...    ${expected_second_b1}
    ...    availableSpotsNumber=${second_entity_b4}[0][availableSpotsNumber]
    ...    totalSpotsNumber=${second_entity_b4}[0][totalSpotsNumber]
    ...    location=${second_entity_b5}[0][location]
    Check Resource Set To    ${expected_second_b1}    ${second_entity_b1}[0]

Setup Initial Context Source Registrations
    [Arguments]    ${context}
    Set Test Variable    ${first_entity_id}    urn:ngsi-ld:OffStreetParking:1
    Set Test Variable    ${second_entity_id}    urn:ngsi-ld:OffStreetParking:2

    ${response}=    Create Entity
    ...    ${first_parking_location_name_payload_filename}
    ...    ${first_entity_id}
    ...    broker_url=${b4_url}
    ...    context=${context}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity
    ...    ${second_full_parking_payload_filename}
    ...    ${second_entity_id}
    ...    broker_url=${b4_url}
    ...    context=${context}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity
    ...    ${first_full_parking_payload_filename}
    ...    ${first_entity_id}
    ...    broker_url=${b5_url}
    ...    context=${context}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity
    ...    ${second_parking_location_name_payload_filename}
    ...    ${second_entity_id}
    ...    broker_url=${b5_url}
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
    ...    ${first_redirect_registration_payload_file_path}
    ...    redirect
    ...    ${b4_url}
    ...    ${b2_url}

    @{third_set}=    Create List
    ...    ${EMPTY}
    ...    ${second_redirect_registration_payload_file_path}
    ...    redirect
    ...    ${b5_url}
    ...    ${b2_url}

    @{fourth_set}=    Create List
    ...    ${EMPTY}
    ...    ${inclusive_registration_payload_file_path}
    ...    inclusive
    ...    ${b3_url}
    ...    ${b1_url}

    @{fifth_set}=    Create List
    ...    ${EMPTY}
    ...    ${first_exclusive_registration_payload_file_path}
    ...    exclusive
    ...    ${b5_url}
    ...    ${b3_url}

    @{sixth_set}=    Create List
    ...    ${EMPTY}
    ...    ${second_exclusive_registration_payload_file_path}
    ...    exclusive
    ...    ${b5_url}
    ...    ${b3_url}

    @{fourth_configuration}=    Create List
    ...    ${first_set}
    ...    ${second_set}
    ...    ${third_set}
    ...    ${fourth_set}
    ...    ${fifth_set}
    ...    ${sixth_set}
    Compose IOP Configuration    ${fourth_configuration}    ld_context=${context}

Delete Entities And Delete Registrations
    @{broker_count}=    Create List
    ...    ${b1_url}
    ...    ${b2_url}
    ...    ${b3_url}
    ...    ${b4_url}
    ...    ${b5_url}
    @{entities_to_delete}=    Create List    ${first_entity_id}    ${second_entity_id}
    Delete Registrations And Entities    ${broker_count}    ${entities_to_delete}
