*** Settings ***
Documentation       Three brokers are set up b1, b2 and b3. b1 has two registrations, one inclusive for the the entity in b2 and one exclusive for the entity in b3.
...                 Check that the OffStreetParking:2 entity returned from b1 has the same availableSpotsNumber and totalSpotsNumber attributes as the ones returned from b2. Check that the OffStreetParking:2 entity returned from b1 has the same location attribute as the one returned from b3.

Resource            ${EXECDIR}/resources/IOPUtils/InteroperabilityUtils.resource

Test Teardown       Delete Entities and Delete Registrations
Test Template       Run Interoperability Scenario


*** Variables ***
${entity_payload_filename}                      interoperability/offStreetParking2-without-location.jsonld
${full_entity_payload_filename}                 interoperability/full-version-of-OffStreetParking2.jsonld
${inclusive_registration_payload_file_path}     csourceRegistrations/interoperability/context-source-registration-inclusive-2.jsonld
${exclusive_registration_payload_file_path}     csourceRegistrations/interoperability/context-source-registration-exclusive-2.jsonld
${b1_url}                                       ${EMPTY}
${b2_url}                                       ${EMPTY}
${b3_url}                                       ${EMPTY}


*** Test Cases ***
IOP_002_01_02_01 Retrieve OffStreetParking:2 With Default Context
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
IOP_002_01_02_02 Retrieve OffStreetParking:2 With User Context
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

    # Client sends an HTTP GET request to b1 to retrieve the Entity OffStreetParking:2
    ${response_b1}=    Retrieve Entity
    ...    ${entity_id}
    ...    context=${context}
    ...    broker_url=${b1_url}
    ...    type=OffStreetParking

    # Agent checks that a success response has been returned and that the Entity OffStreetParking:2 was returned
    Check Response Status Code    200    ${response_b1.status_code}

    # Client sends an HTTP GET request to b2 to retrieve the Entity OffStreetParking:2
    ${response_b2}=    Retrieve Entity
    ...    ${entity_id}
    ...    context=${context}
    ...    broker_url=${b2_url}
    ...    type=OffStreetParking
    Check Response Status Code    200    ${response_b2.status_code}
    ${expected_b2}=    Load Entity    ${entity_payload_filename}    ${entity_id}
    Check Resource Set To    ${expected_b2}    ${response_b2.json()}

    # Client sends an HTTP GET request to b3 to retrieve the Entity OffStreetParking:2
    ${response_b3}=    Retrieve Entity
    ...    ${entity_id}
    ...    context=${context}
    ...    broker_url=${b3_url}
    ...    type=OffStreetParking
    Check Response Status Code    200    ${response_b3.status_code}
    ${expected_b3}=    Load Entity    ${full_entity_payload_filename}    ${entity_id}
    Check Resource Set To    ${expected_b3}    ${response_b3.json()}

    # Agent checks that the Entity returned in step (2) is structured as follows:
    # - The attributes "availableSpotsNumber" and "totalSpotsNumber" match the ones from the Entity returned in step (3)
    # - The attribute "location" matches the one from the Entity returned in step (4)
    ${expected_b1}=    Load Entity    ${entity_payload_filename}    ${entity_id}
    Keep In Dictionary    ${expected_b1}    id    type    availableSpotsNumber    totalSpotsNumber
    Set To Dictionary
    ...    ${expected_b1}
    ...    availableSpotsNumber=${response_b2.json()}[availableSpotsNumber]
    ...    totalSpotsNumber=${response_b2.json()}[totalSpotsNumber]
    ...    location=${response_b3.json()}[location]
    Check Resource Set To    ${expected_b1}    ${response_b1.json()}

Setup Initial Context Source Registrations
    [Arguments]    ${context}
    Set Test Variable    ${entity_id}    urn:ngsi-ld:OffStreetParking:2

    ${response}=    Create Entity
    ...    ${entity_payload_filename}
    ...    ${entity_id}
    ...    broker_url=${b2_url}
    ...    context=${context}
    Check Response Status Code    201    ${response.status_code}

    ${response}=    Create Entity
    ...    ${full_entity_payload_filename}
    ...    ${entity_id}
    ...    broker_url=${b3_url}
    ...    context=${context}
    Check Response Status Code    201    ${response.status_code}

    @{first_set}=    Create List
    ...    ${entity_id}
    ...    ${inclusive_registration_payload_file_path}
    ...    inclusive
    ...    ${b2_url}
    ...    ${b1_url}

    @{second_set}=    Create List
    ...    ${entity_id}
    ...    ${exclusive_registration_payload_file_path}
    ...    exclusive
    ...    ${b3_url}
    ...    ${b1_url}

    @{first_configuration}=    Create List    ${first_set}    ${second_set}
    Compose IOP Configuration    ${first_configuration}    ld_context=${context}

Delete Entities And Delete Registrations
    @{broker_count}=    Create List    ${b1_url}    ${b2_url}    ${b3_url}
    @{entities_to_delete}=    Create List    ${entity_id}
    Delete Registrations And Entities    ${broker_count}    ${entities_to_delete}
