*** Settings ***
Documentation       Three brokers are set up A, B and C. A has two registrations, one inclusive for the the entity created in B and one exclusive for the entity created in C.
...                 Check that the entity returned from A has attributes from both entities in B and C.

Resource            ${EXECDIR}/resources/IOPUtils/InteroperabilityUtils.resource

Test Setup          Setup Initial Context Source Registrations
Test Teardown       Delete Entities and Delete Registrations

*** Variables ***
${entity_payload_filename}                     interoperability/offstreet-parking2-no-location.jsonld
${full_entity_payload_filename}                interoperability/offstreet-parking2-full.jsonld
${inclusive_registration_payload_file_path}    csourceRegistrations/interoperability/context-source-registration-inclusive-2.jsonld
${exclusive_registration_payload_file_path}    csourceRegistrations/interoperability/context-source-registration-exclusive-2.jsonld
${broker_A_url}
${broker_B_url}
${broker_C_url}

*** Test Cases ***
IOP_002_01_02 Retrieve OffStreetParking:2
    [Documentation]    Pre-conditions: no user context. Data only on leaves. B contains OffStreetParking:2 without location. C contains OffStreetParking:2.
    ...                Registrations established: Inclusive in A to B. Exclusive in A to C.
    [Tags]    since_v1.6.1    iop    cnf_01    4_3_3    additive-inclusive    proxy-exclusive    4_3_6    5_7_1

    #Client retrieves OffStreetParking:2 in A and checks for a successful response.
    ${response}=    Retrieve Entity    ${entity_id}    broker_url=${broker_A_url}
    Check Response Status Code    200    ${response.status_code}
    ${payload}=    Set To Dictionary    ${response.json()}

    #Client retrieves OffStreetParking:2 in B and C.
    ${response}=    Retrieve Entity    ${entity_id}   broker_url=${broker_B_url}
    ${first_expected_payload}=    Set To Dictionary    ${response.json()}
    ${response}=    Retrieve Entity    ${entity_id}   broker_url=${broker_C_url}
    ${second_expected_payload}=    Set To Dictionary    ${response.json()}

    #Client checks that the entity returned from A has attributes from both entities in B and C.
    Should Be Equal    ${payload}[availableSpotNumbers][value]    ${first_expected_payload}[availableSpotNumbers][value]
    Should Be Equal    ${payload}[totalSpotsNumber][value]    ${first_expected_payload}[totalSpotsNumber][value]
    Should Be Equal    ${payload}[location][value]    ${second_expected_payload}[location][value]

*** Keywords ***
Setup Initial Context Source Registrations

    ${entity_id}=    Generate Random Parking Entity Id
    Set Suite Variable    ${entity_id}

    ${response}=    Create Entity
    ...    ${entity_payload_filename}
    ...    ${entity_id}
    ...    broker_url=${broker_B_url}
    Check Response Status Code    201    ${response.status_code}

    ${response}=    Create Entity
    ...    ${full_entity_payload_filename}
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
    ...    ${entity_id}
    ...    ${exclusive_registration_payload_file_path}
    ...    exclusive
    ...    ${broker_C_url}
    ...    ${broker_A_url}

    @{first_configuration}=    Create List    ${first_set}    ${second_set}
    Compose IOP Configuration    ${first_configuration}

Delete Entities And Delete Registrations
    @{broker_count}=    Create List    ${broker_A_url}    ${broker_B_url}    ${broker_C_url}
    @{entities_to_delete}=    Create List    ${entity_id}
    Delete Registrations And Entities    ${broker_count}    ${entities_to_delete}