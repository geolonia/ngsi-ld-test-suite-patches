*** Settings ***
Documentation       Three brokers are set up b1, b2 and b3. b1 has two registrations, one inclusive for the entities in b2 and one exclusive for the entity in b3.
...                 Check that OffStreetParking:1 in b1 contains availableSpotsNumber and totalSpotsNumber from b2. Check that OffStreetParking:2 in b1 contains availableSpotsNumber from b2 and location from b3.

Resource            ${EXECDIR}/resources/IOPUtils/InteroperabilityUtils.resource

Test Teardown       Delete Entities and Delete Registrations
Test Template       Run Interoperability Scenario


*** Variables ***
${first_entity_payload_filename}                interoperability/full-version-of-OffStreetParking1.jsonld
${second_entity_payload_filename}               interoperability/full-version-of-OffStreetParking2.jsonld
${third_entity_payload_filename}                interoperability/offStreetParking2-without-location-and-totalSpotsNumber.jsonld
${inclusive_registration_payload_file_path}     csourceRegistrations/interoperability/context-source-registration-inclusive-2.jsonld
${exclusive_registration_payload_file_path}     csourceRegistrations/interoperability/context-source-registration-exclusive-2.jsonld
${b1_url}                                       ${EMPTY}
${b2_url}                                       ${EMPTY}
${b3_url}                                       ${EMPTY}


*** Test Cases ***
IOP_003_01_02_01 Query Entities Of Type OffstreetParking Via POST With Default Context
    [Tags]
    ...    since_v1.6.1
    ...    iop
    ...    cnf_01
    ...    4_3_3
    ...    additive-inclusive
    ...    proxy-exclusive
    ...    4_3_6
    ...    5_7_2
    ...    6_23_2_1
    ...    default-context
    [Setup]    Setup Initial Context Source Registrations    ${core_context}
    ${core_context}
IOP_003_01_02_02 Query Entities Of Type OffstreetParking Via POST With User Context
    [Tags]
    ...    since_v1.6.1
    ...    iop
    ...    cnf_01
    ...    4_3_3
    ...    additive-inclusive
    ...    proxy-exclusive
    ...    4_3_6
    ...    5_7_2
    ...    6_23_2_1
    ...    user-context
    [Setup]    Setup Initial Context Source Registrations    ${ngsild_test_suite_context}
    ${ngsild_test_suite_context}


*** Keywords ***
Run Interoperability Scenario
    [Arguments]    ${context}

    # Client sends an HTTP POST request to b1 to retrieve all Entities with type OffstreetParking
    &{entity_selector}=    Create Dictionary    type=OffStreetParking
    @{entities}=    Create List    ${entity_selector}
    ${response_b1}=    Query Entities Via POST
    ...    entities=${entities}
    ...    broker_url=${b1_url}
    ...    context=${context}

    # Agent checks that a success response has been returned and that the following Entities were returned:
    # - OffstreetParking:1 with the attributes availableSpotsNumber and totalSpotsNumber
    # - OffstreetParking:2 with the attributes availableSpotsNumber and location
    Check Response Status Code    200    ${response_b1.status_code}
    ${expected_b1_ids}=    Create List    ${first_entity_id}    ${second_entity_id}
    Check Response Body Containing Entities URIS set to    ${expected_b1_ids}    ${response_b1.json()}
    ${first_entity_b1}=    Get Value From JSON    ${response_b1.json()}    $[?(@.id=='${first_entity_id}')]
    ${second_entity_b1}=    Get Value From JSON    ${response_b1.json()}    $[?(@.id=='${second_entity_id}')]

    # Client sends an HTTP POST request to b2 to retrieve all Entities with type OffstreetParking
    ${response_b2}=    Query Entities Via POST
    ...    entities=${entities}
    ...    broker_url=${b2_url}
    ...    context=${context}
    Check Response Status Code    200    ${response_b2.status_code}
    ${expected_b2_ids}=    Create List    ${first_entity_id}    ${second_entity_id}
    Check Response Body Containing Entities URIS set to    ${expected_b2_ids}    ${response_b2.json()}
    ${first_entity_b2}=    Get Value From JSON    ${response_b2.json()}    $[?(@.id=='${first_entity_id}')]
    ${second_entity_b2}=    Get Value From JSON    ${response_b2.json()}    $[?(@.id=='${second_entity_id}')]

    # Client sends an HTTP POST request to b3 to retrieve all Entities with type OffstreetParking
    ${response_b3}=    Query Entities Via POST
    ...    entities=${entities}
    ...    broker_url=${b3_url}
    ...    context=${context}
    Check Response Status Code    200    ${response_b3.status_code}
    ${expected_b3_ids}=    Create List    ${second_entity_id}
    Check Response Body Containing Entities URIS set to    ${expected_b3_ids}    ${response_b3.json()}
    ${second_entity_b3}=    Get Value From JSON    ${response_b3.json()}    $[?(@.id=='${second_entity_id}')]

    # Agent checks that b2 returns OffstreetParking:1 and OffstreetParking:2 and b3 returns OffstreetParking:2
    ${expected_first_b2}=    Load Entity    ${first_entity_payload_filename}    ${first_entity_id}
    Check Resource Set To    ${expected_first_b2}    ${first_entity_b2}[0]
    ${expected_second_b2}=    Load Entity    ${third_entity_payload_filename}    ${second_entity_id}
    Check Resource Set To    ${expected_second_b2}    ${second_entity_b2}[0]
    ${expected_second_b3}=    Load Entity    ${second_entity_payload_filename}    ${second_entity_id}
    Check Resource Set To    ${expected_second_b3}    ${second_entity_b3}[0]

    # Agent checks that OffstreetParking:1 returned in step (2) matches b2 and OffstreetParking:2 combines b2 and b3
    ${expected_first_b1}=    Load Entity    ${first_entity_payload_filename}    ${first_entity_id}
    Keep In Dictionary    ${expected_first_b1}    id    type    availableSpotsNumber    totalSpotsNumber
    Set To Dictionary
    ...    ${expected_first_b1}
    ...    availableSpotsNumber=${first_entity_b2}[0][availableSpotsNumber]
    ...    totalSpotsNumber=${first_entity_b2}[0][totalSpotsNumber]
    Check Resource Set To    ${expected_first_b1}    ${first_entity_b1}[0]

    ${expected_second_b1}=    Load Entity    ${third_entity_payload_filename}    ${second_entity_id}
    Keep In Dictionary    ${expected_second_b1}    id    type    availableSpotsNumber
    Set To Dictionary
    ...    ${expected_second_b1}
    ...    availableSpotsNumber=${second_entity_b2}[0][availableSpotsNumber]
    ...    location=${second_entity_b3}[0][location]
    Check Resource Set To    ${expected_second_b1}    ${second_entity_b1}[0]

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
    ...    ${third_entity_payload_filename}
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
