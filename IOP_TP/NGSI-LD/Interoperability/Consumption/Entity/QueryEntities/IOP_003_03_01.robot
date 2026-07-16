*** Settings ***
Documentation       Four brokers are set up A, B, C and D. A has three registrations, one auxiliary for the entities created in B, one inclusive for the entities created in C and one inclusive for the entity created in D.
...                 Check that the entities returned from A match the attributes from the entities in B, C and D.

Resource            ${EXECDIR}/resources/IOPUtils/InteroperabilityUtils.resource

Test Setup          Setup Initial Context Source Registrations
Test Teardown       Delete Entities and Delete Registrations

*** Variables ***
${offstreet_no_location_payload_filename}             interoperability/offstreet-parking2-no-location.jsonld
${first_full_offstreet_payload_filename}              interoperability/offstreet-parking1-full.jsonld
${second_full_offstreet_payload_filename}             interoperability/offstreet-parking2-full.jsonld
${first_inclusive_registration_payload_file_path}     csourceRegistrations/interoperability/context-source-registration-inclusive-1.jsonld
${second_inclusive_registration_payload_file_path}    csourceRegistrations/interoperability/context-source-registration-inclusive-2.jsonld
${auxiliary_registration_payload_file_path}           csourceRegistrations/interoperability/context-source-registration-auxiliary-1.jsonld
${broker_A_url}
${broker_B_url}
${broker_C_url}
${broker_D_url}

*** Test Cases ***
IOP_003_03_01 Query Entities Of Type OffstreetParking Via GET
    [Documentation]    Pre-conditions: no user context. Data only on leaves. B contains OffStreetParking:2 without location. C contains OffStreetParking:1. D contains OffStreetParking:1 without location.
    ...                Registrations established: Auxiliary in A to B. Inclusive in A to C. Inclusive in A to D.
    [Tags]    since_v1.6.1    iop    cnf_03    4_3_3    additive-inclusive    additive-auxiliary    4_3_6    5_7_2    6_4_3_1

    #Client queries all entities with type OffstreetParking in A and checks for a successful response. 
    ${response}=    Query Entities    entity_types=OffstreetParking    broker_url=${broker_A_url}
    Check Response Status Code    200    ${response.status_code}

    &{payload}=    Evaluate    {i['id']: i for i in ${response.json()}}
    ${first_parking_payload}=    Get From Dictionary    ${payload}    OffstreetParking:1
    ${second_parking_payload}=    Get From Dictionary    ${payload}    OffstreetParking:2

    #Client queries all entities with type OffstreetParking in B, C and D.
    ${response}=    Query Entities    entity_types=OffstreetParking    broker_url=${broker_B_url}
    ${payload}=    Evaluate    {i['id']: i for i in ${response.json()}}
    ${expected_parking1}=    Get From Dictionary    ${payload}    OffstreetParking:2

    ${response}=    Query Entities    entity_types=OffstreetParking    broker_url=${broker_C_url}
    ${payload}=    Evaluate    {i['id']: i for i in ${response.json()}}
    ${expected_parking2}=    Get From Dictionary    ${payload}    OffstreetParking:1

    ${response}=    Query Entities    entity_types=OffstreetParking    broker_url=${broker_D_url}
    ${payload}=    Evaluate    {i['id']: i for i in ${response.json()}}
    ${expected_parking3}=    Get From Dictionary    ${payload}    OffstreetParking:2

    #Client checks that the attributes of the entities in A are the same as the ones in B, C and D.
    Should Be Equal    ${first_parking_payload}[name]    ${expected_parking2}[name]
    Should Be Equal    ${first_parking_payload}[location]    ${expected_parking2}[location]
    Should Be Equal    ${second_parking_payload}[availableSpotsNumber]    ${expected_parking3}[availableSpotsNumber]
    Should Be Equal    ${second_parking_payload}[totalSpotsNumber]    ${expected_parking3}[totalSpotsNumber]
    Should Not Be Equal    ${second_parking_payload}[availableSpotsNumber]    ${expected_parking1}[availableSpotsNumber]

*** Keywords ***
Setup Initial Context Source Registrations

    ${entity_id}=    Generate Random Parking Entity Id
    Set Suite Variable    ${entity_id}

    ${response}=    Create Entity    ${offstreet_no_location_payload_filename}    ${entity_id}    broker_url=${broker_B_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${first_full_offstreet_payload_filename}    ${entity_id}    broker_url=${broker_C_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${second_full_offstreet_payload_filename}    ${entity_id}    broker_url=${broker_D_url}
    Check Response Status Code    201    ${response.status_code}

    @{first_set}=    Create List
    ...    ${entity_id}
    ...    ${auxiliary_registration_payload_file_path}
    ...    auxiliary
    ...    ${broker_B_url}
    ...    ${broker_A_url}

    @{second_set}=    Create List
    ...    ${entity_id}
    ...    ${first_inclusive_registration_payload_file_path}
    ...    inclusive
    ...    ${broker_C_url}
    ...    ${broker_A_url}

    @{third_set}=    Create List
    ...    ${entity_id}
    ...    ${second_inclusive_registration_payload_file_path}
    ...    inclusive
    ...    ${broker_D_url}
    ...    ${broker_A_url}

    @{third_configuration}=    Create List    ${first_set}    ${second_set}    ${third_set}
    Compose IOP Configuration    ${third_configuration}

Delete Entities And Delete Registrations
    @{broker_count}=    Create List    ${broker_A_url}    ${broker_B_url}    ${broker_C_url}    ${broker_D_url}
    @{entities_to_delete}=    Create List    ${entity_id}
    Delete Registrations And Entities    ${broker_count}    ${entities_to_delete}