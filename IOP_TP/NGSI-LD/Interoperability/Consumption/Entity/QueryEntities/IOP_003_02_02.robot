*** Settings ***
Documentation       Four brokers are set up b1, b2, b3 and b4. b1 has five registrations, two inclusive for the entities in b2, one redirect for the entities in b3 and two redirect for the entity in b4.
...                 Check that the Vehicle:1 entity in b1 is the same as the one in b2. Check that the entity OffStreetParking:1 in b1 is the same as the one in b3. Check that the entities Vehicle:2 and OffStreetParking:2 in b1 are the same as the ones in b4.

Resource            ${EXECDIR}/resources/IOPUtils/InteroperabilityUtils.resource

Test Teardown       Delete Entities and Delete Registrations
Test Template       Run Interoperability Scenario


*** Variables ***
${first_vehicle_payload_filename}                       interoperability/full-version-of-Vehicle1.jsonld
${second_vehicle_payload_filename}                      interoperability/full-version-of-Vehicle2.jsonld
${first_offstreet_payload_filename}                     interoperability/full-version-of-OffStreetParking1.jsonld
${second_offstreet_payload_filename}                    interoperability/full-version-of-OffStreetParking2.jsonld
${first_parking_location_name_payload_filename}         interoperability/offStreetParking1-with-location-and-name-only.jsonld
${second_parking_location_name_payload_filename}        interoperability/offStreetParking2-with-location-and-name-only.jsonld
${first_inclusive_registration_payload_file_path}       csourceRegistrations/interoperability/context-source-registration-inclusive-2.jsonld
${second_inclusive_registration_payload_file_path}      csourceRegistrations/interoperability/context-source-registration-inclusive-3.jsonld
${first_redirect_registration_payload_file_path}        csourceRegistrations/interoperability/context-source-registration-redirect-2.jsonld
${second_redirect_registration_payload_file_path}       csourceRegistrations/interoperability/context-source-registration-redirect-3.jsonld
${third_redirect_registration_payload_file_path}        csourceRegistrations/interoperability/context-source-registration-redirect-4.jsonld
${b1_url}                                               ${EMPTY}
${b2_url}                                               ${EMPTY}
${b3_url}                                               ${EMPTY}
${b4_url}                                               ${EMPTY}


*** Test Cases ***
IOP_003_02_02_01 Query Entities Of Type OffstreetParking And Vehicle With Attrs With Default Context
    [Tags]
    ...    since_v1.6.1
    ...    iop
    ...    cnf_02
    ...    4_3_3
    ...    additive-inclusive
    ...    proxy-redirect
    ...    4_3_6
    ...    5_7_2
    ...    6_4_3_1
    ...    default-context
    [Setup]    Setup Initial Context Source Registrations    ${core_context}
    ${core_context}
IOP_003_02_02_02 Query Entities Of Type OffstreetParking And Vehicle With Attrs With User Context
    [Tags]
    ...    since_v1.6.1
    ...    iop
    ...    cnf_02
    ...    4_3_3
    ...    additive-inclusive
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

    # Client sends an HTTP GET request to b1 to retrieve the "location" Property from Entities having type OffstreetParking or Vehicle
    ${response_b1}=    Query Entities
    ...    entity_types=OffStreetParking,Vehicle
    ...    attrs=location
    ...    broker_url=${b1_url}
    ...    context=${context}

    # Agent checks that a success response has been returned and that all four Entities were returned with the "location" Property only
    Check Response Status Code    200    ${response_b1.status_code}
    ${expected_b1_ids}=    Create List
    ...    ${first_parking_entity_id}
    ...    ${second_parking_entity_id}
    ...    ${first_vehicle_entity_id}
    ...    ${second_vehicle_entity_id}
    Check Response Body Containing Entities URIS set to    ${expected_b1_ids}    ${response_b1.json()}
    ${first_parking_b1}=    Get Value From JSON    ${response_b1.json()}    $[?(@.id=='${first_parking_entity_id}')]
    ${second_parking_b1}=    Get Value From JSON    ${response_b1.json()}    $[?(@.id=='${second_parking_entity_id}')]
    ${first_vehicle_b1}=    Get Value From JSON    ${response_b1.json()}    $[?(@.id=='${first_vehicle_entity_id}')]
    ${second_vehicle_b1}=    Get Value From JSON    ${response_b1.json()}    $[?(@.id=='${second_vehicle_entity_id}')]

    # Client sends an HTTP GET request to b2 to retrieve the "location" Property from Entities having type OffstreetParking or Vehicle
    ${response_b2}=    Query Entities
    ...    entity_types=OffStreetParking,Vehicle
    ...    attrs=location
    ...    broker_url=${b2_url}
    ...    context=${context}
    Check Response Status Code    200    ${response_b2.status_code}
    ${expected_b2_ids}=    Create List    ${first_parking_entity_id}    ${first_vehicle_entity_id}
    Check Response Body Containing Entities URIS set to    ${expected_b2_ids}    ${response_b2.json()}
    ${first_parking_b2}=    Get Value From JSON    ${response_b2.json()}    $[?(@.id=='${first_parking_entity_id}')]
    ${first_vehicle_b2}=    Get Value From JSON    ${response_b2.json()}    $[?(@.id=='${first_vehicle_entity_id}')]

    # Client sends an HTTP GET request to b3 to retrieve the "location" Property from Entities having type OffstreetParking or Vehicle
    ${response_b3}=    Query Entities
    ...    entity_types=OffStreetParking,Vehicle
    ...    attrs=location
    ...    broker_url=${b3_url}
    ...    context=${context}
    Check Response Status Code    200    ${response_b3.status_code}
    ${expected_b3_ids}=    Create List    ${first_parking_entity_id}    ${second_parking_entity_id}
    Check Response Body Containing Entities URIS set to    ${expected_b3_ids}    ${response_b3.json()}
    ${first_parking_b3}=    Get Value From JSON    ${response_b3.json()}    $[?(@.id=='${first_parking_entity_id}')]
    ${second_parking_b3}=    Get Value From JSON    ${response_b3.json()}    $[?(@.id=='${second_parking_entity_id}')]

    # Client sends an HTTP GET request to b4 to retrieve the "location" Property from Entities having type OffstreetParking or Vehicle
    ${response_b4}=    Query Entities
    ...    entity_types=OffStreetParking,Vehicle
    ...    attrs=location
    ...    broker_url=${b4_url}
    ...    context=${context}
    Check Response Status Code    200    ${response_b4.status_code}
    ${expected_b4_ids}=    Create List    ${second_parking_entity_id}    ${second_vehicle_entity_id}
    Check Response Body Containing Entities URIS set to    ${expected_b4_ids}    ${response_b4.json()}
    ${second_parking_b4}=    Get Value From JSON    ${response_b4.json()}    $[?(@.id=='${second_parking_entity_id}')]
    ${second_vehicle_b4}=    Get Value From JSON    ${response_b4.json()}    $[?(@.id=='${second_vehicle_entity_id}')]

    ${first_parking_expected}=    Load Entity
    ...    ${first_parking_location_name_payload_filename}
    ...    ${first_parking_entity_id}
    Keep In Dictionary    ${first_parking_expected}    id    type    location
    Check Resource Set To    ${first_parking_expected}    ${first_parking_b2}[0]
    Check Resource Set To    ${first_parking_expected}    ${first_parking_b3}[0]
    ${second_parking_expected}=    Load Entity
    ...    ${second_parking_location_name_payload_filename}
    ...    ${second_parking_entity_id}
    Keep In Dictionary    ${second_parking_expected}    id    type    location
    Check Resource Set To    ${second_parking_expected}    ${second_parking_b3}[0]
    Check Resource Set To    ${second_parking_expected}    ${second_parking_b4}[0]
    ${first_vehicle_expected}=    Load Entity    ${first_vehicle_payload_filename}    ${first_vehicle_entity_id}
    Keep In Dictionary    ${first_vehicle_expected}    id    type    location
    Check Resource Set To    ${first_vehicle_expected}    ${first_vehicle_b2}[0]
    ${second_vehicle_expected}=    Load Entity    ${second_vehicle_payload_filename}    ${second_vehicle_entity_id}
    Keep In Dictionary    ${second_vehicle_expected}    id    type    location
    Check Resource Set To    ${second_vehicle_expected}    ${second_vehicle_b4}[0]

    # Agent checks that Vehicle:1 matches b2, OffstreetParking:1 matches b3, and Vehicle:2 and OffstreetParking:2 match b4
    Check Resource Set To    ${first_parking_b3}[0]    ${first_parking_b1}[0]
    Check Resource Set To    ${second_parking_b4}[0]    ${second_parking_b1}[0]
    Check Resource Set To    ${first_vehicle_b2}[0]    ${first_vehicle_b1}[0]
    Check Resource Set To    ${second_vehicle_b4}[0]    ${second_vehicle_b1}[0]

Setup Initial Context Source Registrations
    [Arguments]    ${context}
    Set Test Variable    ${first_parking_entity_id}    urn:ngsi-ld:OffStreetParking:1
    Set Test Variable    ${second_parking_entity_id}    urn:ngsi-ld:OffStreetParking:2
    Set Test Variable    ${first_vehicle_entity_id}    urn:ngsi-ld:Vehicle:1
    Set Test Variable    ${second_vehicle_entity_id}    urn:ngsi-ld:Vehicle:2

    ${response}=    Create Entity
    ...    ${first_vehicle_payload_filename}
    ...    ${first_vehicle_entity_id}
    ...    broker_url=${b2_url}
    ...    context=${context}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity
    ...    ${first_offstreet_payload_filename}
    ...    ${first_parking_entity_id}
    ...    broker_url=${b2_url}
    ...    context=${context}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity
    ...    ${first_parking_location_name_payload_filename}
    ...    ${first_parking_entity_id}
    ...    broker_url=${b3_url}
    ...    context=${context}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity
    ...    ${second_offstreet_payload_filename}
    ...    ${second_parking_entity_id}
    ...    broker_url=${b3_url}
    ...    context=${context}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity
    ...    ${second_parking_location_name_payload_filename}
    ...    ${second_parking_entity_id}
    ...    broker_url=${b4_url}
    ...    context=${context}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity
    ...    ${second_vehicle_payload_filename}
    ...    ${second_vehicle_entity_id}
    ...    broker_url=${b4_url}
    ...    context=${context}
    Check Response Status Code    201    ${response.status_code}

    @{first_set}=    Create List
    ...    ${EMPTY}
    ...    ${first_inclusive_registration_payload_file_path}
    ...    inclusive
    ...    ${b2_url}
    ...    ${b1_url}

    @{second_set}=    Create List
    ...    ${EMPTY}
    ...    ${second_inclusive_registration_payload_file_path}
    ...    inclusive
    ...    ${b2_url}
    ...    ${b1_url}

    @{third_set}=    Create List
    ...    ${EMPTY}
    ...    ${first_redirect_registration_payload_file_path}
    ...    redirect
    ...    ${b3_url}
    ...    ${b1_url}

    @{fourth_set}=    Create List
    ...    ${EMPTY}
    ...    ${second_redirect_registration_payload_file_path}
    ...    redirect
    ...    ${b4_url}
    ...    ${b1_url}

    @{fifth_set}=    Create List
    ...    ${EMPTY}
    ...    ${third_redirect_registration_payload_file_path}
    ...    redirect
    ...    ${b4_url}
    ...    ${b1_url}

    @{second_configuration}=    Create List
    ...    ${first_set}
    ...    ${second_set}
    ...    ${third_set}
    ...    ${fourth_set}
    ...    ${fifth_set}
    Compose IOP Configuration    ${second_configuration}    ld_context=${context}

Delete Entities And Delete Registrations
    @{broker_count}=    Create List    ${b1_url}    ${b2_url}    ${b3_url}    ${b4_url}
    @{entities_to_delete}=    Create List
    ...    ${first_parking_entity_id}
    ...    ${second_parking_entity_id}
    ...    ${first_vehicle_entity_id}
    ...    ${second_vehicle_entity_id}
    Delete Registrations And Entities    ${broker_count}    ${entities_to_delete}
