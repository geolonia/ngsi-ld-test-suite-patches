*** Settings ***
Documentation       Three brokers are set up A, B and C. A has two registrations, one inclusive for the entities created in B and one exclusive for the entity created in C.
...                 The client sends a HTTP GET request to check that quering the offparking type returns the entities in B and C.

Resource            ${EXECDIR}/resources/IOPUtils/InteroperabilityUtils.resource

Test Setup          Setup Initial Context Source Registrations
Test Teardown       Delete Entities and Delete Registrations

*** Variables ***
${first_entity_payload_filename}               interoperability/offstreet-parking1-full.jsonld
${second_entity_payload_filename}              interoperability/offstreet-parking2-full.jsonld
${third_entity_payload_filename}               interoperability/offstreet-parking2-no-location-and-totalspotsnumber.jsonld
${inclusive_registration_payload_file_path}    csourceRegistrations/interoperability/context-source-registration-inclusive-2.jsonld
${exclusive_registration_payload_file_path}    csourceRegistrations/interoperability/context-source-registration-exclusive-2.jsonld
${broker_A_url}
${broker_B_url}
${broker_C_url}

*** Test Cases ***
IOP_003_01_01 Query Entities Of Type OffstreetParking Via GET
    [Documentation]    Pre-conditions: no user context. Data only on leaves. B contains OffStreetParking:1 and OffStreetParking:2 without location and totalSpotsNumber. C contains OffStreetParking:2.
    ...                Registrations established: Inclusive in A to B. Exclusive in A to C.
    [Tags]    since_v1.6.1    iop    cnf_01    4_3_3    additive-inclusive    proxy-exclusive    4_3_6    5_7_2    6_4_3_1

    #Agent queries all entities with type OffstreetParking in A and checks for a successful response that contains the attributes of both entities in B and C.
    ${response}=    Query Entities    entity_types=OffstreetParking    broker_url=${broker_A_url}
    Check Response Status Code    200    ${response.status_code}
    @{payload}=    Set Variable   ${response.json()}
    Should Contain    ${payload}\[OffstreetParking1]    availableSpotsNumber
    Should Contain    ${payload}\[OffstreetParking1]    totalSpotsNumber
    Should Contain    ${payload}\[OffstreetParking2]    availableSpotsNumber
    Should Contain    ${payload}\[OffstreetParking2]    location

    #Agent queries all entities with type OffstreetParking in B and C
    ${response}=    Query Entities    entity_types=OffstreetParking    broker_url=${broker_B_url}
    @{first_expected_payload}=    Set Variable    ${response.json()}
    ${entity_ids}=    Create List    ${entity_id}    ${second_entity_id}
    Check Response Body Containing Entities URIS set to    ${entity_ids}    ${response.json()}

    ${response}=    Query Entities    entity_types=OffstreetParking    broker_url=${broker_C_url}
    @{second_expected_payload}=    Set Variable    ${response.json()}
    Check Response Body Containing Entities URIS set to    ${entity_id}    ${response.json()}

    #Agent checks that OffstreetParking:1 in A is the same as the one in B and that OffstreetParking:2 in A contains the attributes of both OffstreetParking:2 in B and C.
    Should Be Equal    ${payload}\[OffstreetParking1]    ${first_expected_payload}\[OffstreetParking1]
    Should Contain    ${payload}\[OffstreetParking2]    ${first_expected_payload}\[OffstreetParking2][totalSpotsNumber]
    Should Contain    ${payload}\[OffstreetParking2]    ${second_expected_payload}\[OffstreetParking2][location]

*** Keywords ***
Setup Initial Context Source Registrations

    ${entity_id}=    Generate Random Parking Entity Id
    Set Suite Variable    ${entity_id}
    ${second_entity_id}=    Generate Random Parking Entity Id
    Set Suite Variable    ${second_entity_id}

    ${response}=    Create Entity
    ...    ${first_entity_payload_filename}
    ...    ${entity_id}
    ...    broker_url=${broker_B_url}
    Check Response Status Code    201    ${response.status_code}

    ${response}=    Create Entity
    ...    ${third_entity_payload_filename}
    ...    ${second_entity_id}
    ...    broker_url=${broker_B_url}
    Check Response Status Code    201    ${response.status_code}

    ${response}=    Create Entity
    ...    ${second_entity_payload_filename}
    ...    ${entity_id}
    ...    broker_url=${broker_C_url}
    Check Response Status Code    201    ${response.status_code}

    @{first_set}=    Create List
    ...    ${entity_id}
    ...    ${inclusive_registration_payload_file_path}
    ...    inclusive
    ...    ${broker_B_url}
    ...    ${broker_A_url}

    @{second_set}=    Create List
    ...    ${second_entity_id}
    ...    ${inclusive_registration_payload_file_path}
    ...    inclusive
    ...    ${broker_B_url}
    ...    ${broker_A_url}

    @{third_set}=    Create List
    ...    ${entity_id}
    ...    ${exclusive_registration_payload_file_path}
    ...    exclusive
    ...    ${broker_C_url}
    ...    ${broker_A_url}

    @{first_configuration}=    Create List    ${first_set}    ${second_set}    ${third_set}
    Compose IOP Configuration    ${first_configuration}

Delete Entities And Delete Registrations
    @{broker_count}=    Create List    ${broker_A_url}    ${broker_B_url}    ${broker_C_url}
    @{entities_to_delete}=    Create List    ${entity_id}    ${second_entity_id}
    Delete Registrations And Entities    ${broker_count}    ${entities_to_delete}