*** Settings ***
Documentation       Five brokers are set up b1, b2, b3, b4 and b5. b1 has two registrations, one auxiliary for the entity in b2, one inclusive for the entity in b3. b2 has two registrations, one redirect for the entity in b4 and one redirect for the entity in b5. b3 shall establish one exclusive registration to b5.
...                 Check that the entity returned from b1 has the same availableSpotsNumber and totalSpotsNumber as the ones found in b2. Check that the entity returned from b1 has the same name attribute as the one in b3. Check that the entity returned from b1 has the same location attribute as the one in b5.

Resource            ${EXECDIR}/resources/IOPUtils/InteroperabilityUtils.resource

Test Teardown       Delete Entities and Delete Registrations
Test Template       Run Interoperability Scenario


*** Variables ***
${no_location_entity_payload_filename}                  interoperability/offStreetParking1-without-location.jsonld
${location_name_entity_payload_filename}                interoperability/offStreetParking1-with-location-and-name-only.jsonld
${full_entity_payload_filename}                         interoperability/full-version-of-OffStreetParking1.jsonld
${inclusive_registration_payload_file_path}             csourceRegistrations/interoperability/context-source-registration-inclusive-1.jsonld
${auxiliary_registration_payload_file_path}             csourceRegistrations/interoperability/context-source-registration-auxiliary-1.jsonld
${exclusive_registration_payload_file_path}             csourceRegistrations/interoperability/context-source-registration-exclusive-3.jsonld
${first_redirect_registration_payload_file_path}        csourceRegistrations/interoperability/context-source-registration-redirect-2.jsonld
${second_redirect_registration_payload_file_path}       csourceRegistrations/interoperability/context-source-registration-redirect-3.jsonld
${b1_url}                                               ${EMPTY}
${b2_url}                                               ${EMPTY}
${b3_url}                                               ${EMPTY}
${b4_url}                                               ${EMPTY}
${b5_url}                                               ${EMPTY}


*** Test Cases ***
IOP_002_04_02_01 Retrieve OffStreetParking:1 Location Attribute With Default Context
    [Tags]
    ...    since_v1.6.1
    ...    iop
    ...    cnf_04
    ...    4_3_3
    ...    additive-inclusive
    ...    additive-auxiliary
    ...    proxy-redirect
    ...    proxy-exclusive
    ...    4_3_6
    ...    5_7_1
    ...    default-context
    [Setup]    Setup Initial Context Source Registrations    ${core_context}
    ${core_context}
IOP_002_04_02_02 Retrieve OffStreetParking:1 Location Attribute With User Context
    [Tags]
    ...    since_v1.6.1
    ...    iop
    ...    cnf_04
    ...    4_3_3
    ...    additive-inclusive
    ...    additive-auxiliary
    ...    proxy-redirect
    ...    proxy-exclusive
    ...    4_3_6
    ...    5_7_1
    ...    user-context
    [Setup]    Setup Initial Context Source Registrations    ${ngsild_test_suite_context}
    ${ngsild_test_suite_context}


*** Keywords ***
Run Interoperability Scenario
    [Arguments]    ${context}

    # Client sends an HTTP GET request to b1 to retrieve the Entity OffStreetParking:1
    ${response_b1}=    Retrieve Entity
    ...    ${entity_id}
    ...    context=${context}
    ...    broker_url=${b1_url}
    ...    type=OffStreetParking

    # Agent checks that a success response has been returned and that the Entity OffStreetParking:1 with the "location" Property was returned
    Check Response Status Code    200    ${response_b1.status_code}

    # Client sends an HTTP GET request to b2 (with local=true) to retrieve the Entity OffStreetParking:1
    ${response_b2}=    Retrieve Entity
    ...    ${entity_id}
    ...    local=true
    ...    context=${context}
    ...    broker_url=${b2_url}
    ...    type=OffStreetParking
    Check Response Status Code    200    ${response_b2.status_code}
    ${expected_b2}=    Load Entity    ${no_location_entity_payload_filename}    ${entity_id}
    Check Resource Set To    ${expected_b2}    ${response_b2.json()}

    # Client sends an HTTP GET request to b3 (with local=true) to retrieve the Entity OffStreetParking:1
    ${response_b3}=    Retrieve Entity
    ...    ${entity_id}
    ...    local=true
    ...    context=${context}
    ...    broker_url=${b3_url}
    ...    type=OffStreetParking
    Check Response Status Code    200    ${response_b3.status_code}
    ${expected_b3}=    Load Entity    ${no_location_entity_payload_filename}    ${entity_id}
    Check Resource Set To    ${expected_b3}    ${response_b3.json()}

    # Client sends an HTTP GET request to b5 (with local=true) to retrieve the Entity OffStreetParking:1
    ${response_b5}=    Retrieve Entity
    ...    ${entity_id}
    ...    local=true
    ...    context=${context}
    ...    broker_url=${b5_url}
    ...    type=OffStreetParking
    Check Response Status Code    200    ${response_b5.status_code}
    ${expected_b5}=    Load Entity    ${location_name_entity_payload_filename}    ${entity_id}
    Check Resource Set To    ${expected_b5}    ${response_b5.json()}

    # Agent checks that the Entity returned in step (2) is structured as follows:
    # - The attributes "availableSpotsNumber" and "totalSpotsNumber" match the ones from the Entity returned in step (3)
    # - The attribute "name" matches the one from the Entity returned in step (4)
    # - The attribute "location" matches the one from the Entity returned in step (5)
    ${expected_b1}=    Load Entity    ${no_location_entity_payload_filename}    ${entity_id}
    Set To Dictionary
    ...    ${expected_b1}
    ...    availableSpotsNumber=${response_b2.json()}[availableSpotsNumber]
    ...    totalSpotsNumber=${response_b2.json()}[totalSpotsNumber]
    ...    name=${response_b3.json()}[name]
    ...    location=${response_b5.json()}[location]
    Check Resource Set To    ${expected_b1}    ${response_b1.json()}

Setup Initial Context Source Registrations
    [Arguments]    ${context}
    Set Test Variable    ${entity_id}    urn:ngsi-ld:OffStreetParking:1
    ${response}=    Create Entity
    ...    ${no_location_entity_payload_filename}
    ...    ${entity_id}
    ...    broker_url=${b1_url}
    ...    context=${context}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity
    ...    ${no_location_entity_payload_filename}
    ...    ${entity_id}
    ...    broker_url=${b2_url}
    ...    context=${context}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity
    ...    ${no_location_entity_payload_filename}
    ...    ${entity_id}
    ...    broker_url=${b3_url}
    ...    context=${context}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity
    ...    ${full_entity_payload_filename}
    ...    ${entity_id}
    ...    broker_url=${b4_url}
    ...    context=${context}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity
    ...    ${location_name_entity_payload_filename}
    ...    ${entity_id}
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
    ...    ${exclusive_registration_payload_file_path}
    ...    exclusive
    ...    ${b5_url}
    ...    ${b3_url}

    @{fourth_configuration}=    Create List
    ...    ${first_set}
    ...    ${second_set}
    ...    ${third_set}
    ...    ${fourth_set}
    ...    ${fifth_set}
    Compose IOP Configuration    ${fourth_configuration}    ld_context=${context}

Delete Entities And Delete Registrations
    @{broker_count}=    Create List
    ...    ${b1_url}
    ...    ${b2_url}
    ...    ${b3_url}
    ...    ${b4_url}
    ...    ${b5_url}
    @{entities_to_delete}=    Create List    ${entity_id}
    Delete Registrations And Entities    ${broker_count}    ${entities_to_delete}
