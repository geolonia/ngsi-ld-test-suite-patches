*** Settings ***
Documentation       Five brokers are set up A, B, C, D and E. A has two registrations, one auxiliary for the entity created in B, one inclusive for the entity created in C. B has two registrations, one redirect for the entity created in D and one redirect for the entity created in E. C has two exclusive registrations to E.
...                 Check that the entities found in B, C, D and E can be queried from A via HTTP GET and said entities have the same attributes as the ones queried from A.

Resource            ${EXECDIR}/resources/IOPUtils/InteroperabilityUtils.resource

Test Setup          Setup Initial Context Source Registrations
Test Teardown       Delete Entities and Delete Registrations

*** Variables ***
${first_parking_location_name_payload_filename}       interoperability/offstreet-parking1-location-and-name.jsonld
${second_parking_location_name_payload_filename}      interoperability/offstreet-parking2-location-and-name.jsonld
${first_full_parking_payload_filename}                interoperability/offstreet-parking1-full.jsonld
${second_full_parking_payload_filename}               interoperability/offstreet-parking2-full.jsonld
${auxiliary_registration_payload_file_path}           csourceRegistrations/interoperability/context-source-registration-auxiliary-2.jsonld
${inclusive_registration_payload_file_path}           csourceRegistrations/interoperability/context-source-registration-inclusive-1.jsonld
${first_exclusive_registration_payload_file_path}     csourceRegistrations/interoperability/context-source-registration-exclusive-2.jsonld
${second_exclusive_registration_payload_file_path}    csourceRegistrations/interoperability/context-source-registration-exclusive-3.jsonld
${first_redirect_registration_payload_file_path}      csourceRegistrations/interoperability/context-source-registration-redirect-1.jsonld
${second_redirect_registration_payload_file_path}     csourceRegistrations/interoperability/context-source-registration-redirect-2.jsonld
${broker_A_url}
${broker_B_url}
${broker_C_url}
${broker_D_url}
${broker_E_url}

*** Test Cases ***
IOP_003_04_01 Query Entities Of Type OffstreetParking Via GET
    [Documentation]    Pre-conditions: no user context. Data only on leaves. D contains OffStreetParking:1 with location and name only and OffStreetParking:2. E contains OffStreetParking:1 and OffStreetParking:2 with location and name only.
    ...                Registrations established: Auxiliary in A to B. Inclusive in A to C. Redirect in B to D. Redirect in B to E. Exclusive in C to E.
    [Tags]    since_v1.6.1    iop    cnf_04    4_3_3    additive-inclusive    additive-auxiliary    proxy-exclusive    proxy-redirect    4_3_6    5_7_2    6_4_3_1

    #Client queries all entities with type OffstreetParking in A and checks for a successful response.
    ${response}=    Query Entities    entity_types=OffstreetParking    broker_url=${broker_A_url}
    Check Response Status Code    200    ${response.status_code}

    &{payload}=    Evaluate    {i['id']: i for i in ${response.json()}}
    ${first_parking_payload}=    Get From Dictionary    ${payload}    OffstreetParking:1
    ${second_parking_payload}=    Get From Dictionary    ${payload}    OffstreetParking:2
    Should Contain    ${first_parking_payload}    location
    Should Contain    ${second_parking_payload}    availableSpotsNumber
    Should Contain    ${second_parking_payload}    totalSpotsNumber
    Should Contain    ${second_parking_payload}    location

    #Client queries all entities with type OffstreetParking in D and E.
    ${response}=    Query Entities    entity_types=OffstreetParking    broker_url=${broker_D_url}
    ${payload}=    Evaluate    {i['id']: i for i in ${response.json()}}
    ${expected_entity1}=    Get From Dictionary    ${payload}    OffstreetParking:2
    ${response}=    Query Entities    entity_types=OffstreetParking    broker_url=${broker_E_url}
    ${payload}=    Evaluate    {i['id']: i for i in ${response.json()}}
    ${expected_entity2}=    Get From Dictionary    ${payload}    OffstreetParking:1
    ${expected_entity3}=    Get From Dictionary    ${payload}    OffstreetParking:2

    #Client checks that the attributes of the entities in A are the same as the ones in D and E.
    Should Be Equal    ${first_parking_payload}[location]    ${expected_entity2}[location]
    Should Be Equal    ${second_parking_payload}[availableSpotsNumber]    ${expected_entity1}[availableSpotsNumber]
    Should Be Equal    ${second_parking_payload}[totalSpotsNumber]    ${expected_entity1}[totalSpotsNumber]
    Should Be Equal    ${second_parking_payload}[location]    ${expected_entity3}[location]

*** Keywords ***
Setup Initial Context Source Registrations

    ${entity_id}=    Generate Random Parking Entity Id
    Set Suite Variable    ${entity_id}
    ${second_entity_id}=    Generate Random Parking Entity Id
    Set Suite Variable    ${second_entity_id}

    ${response}=    Create Entity    ${first_parking_location_name_payload_filename}    ${entity_id}    broker_url=${broker_D_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${second_full_parking_payload_filename}    ${second_entity_id}    broker_url=${broker_D_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${first_full_parking_payload_filename}    ${entity_id}    broker_url=${broker_E_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${second_parking_location_name_payload_filename}    ${second_entity_id}    broker_url=${broker_E_url}
    Check Response Status Code    201    ${response.status_code}

    @{first_set}=    Create List
    ...    ${entity_id}
    ...    ${auxiliary_registration_payload_file_path}
    ...    auxiliary
    ...    ${broker_B_url}
    ...    ${broker_A_url}

    @{second_set}=    Create List
    ...    ${entity_id}
    ...    ${first_redirect_registration_payload_file_path}
    ...    redirect
    ...    ${broker_D_url}
    ...    ${broker_B_url}

    @{third_set}=    Create List
    ...    ${second_entity_id}
    ...    ${second_redirect_registration_payload_file_path}
    ...    redirect
    ...    ${broker_E_url}
    ...    ${broker_B_url}

    @{fourth_set}=    Create List
    ...    ${entity_id}
    ...    ${inclusive_registration_payload_file_path}
    ...    inclusive
    ...    ${broker_C_url}
    ...    ${broker_A_url}

    @{fifth_set}=    Create List
    ...    ${second_entity_id}
    ...    ${first_exclusive_registration_payload_file_path}
    ...    exclusive
    ...    ${broker_E_url}
    ...    ${broker_C_url}

    @{sixth_set}=    Create List
    ...    ${entity_id}
    ...    ${second_exclusive_registration_payload_file_path}
    ...    exclusive
    ...    ${broker_E_url}
    ...    ${broker_C_url}

    @{fourth_configuration}=    Create List    ${first_set}    ${second_set}    ${third_set}    ${fourth_set}    ${fifth_set}    ${sixth_set}
    Compose IOP Configuration    ${fourth_configuration}

Delete Entities And Delete Registrations
    @{broker_count}=    Create List    ${broker_A_url}    ${broker_B_url}    ${broker_C_url}    ${broker_D_url}    ${broker_E_url}
    @{entities_to_delete}=    Create List    ${entity_id}    ${second_entity_id}
    Delete Registrations And Entities    ${broker_count}    ${entities_to_delete}