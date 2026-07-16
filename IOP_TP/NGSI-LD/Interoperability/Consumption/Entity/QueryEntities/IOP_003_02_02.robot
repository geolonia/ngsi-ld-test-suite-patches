*** Settings ***
Documentation       Four brokers are set up A, B, C and D. A has five registrations, two inclusive for the entities created in B, one redirect for the entities created in C and two redirect for the entity created in D.
...                 Check that the entities in B, C and D and said entities have the same attributes as the ones queried from A.

Resource            ${EXECDIR}/resources/IOPUtils/InteroperabilityUtils.resource

Test Setup          Setup Initial Context Source Registrations
Test Teardown       Delete Entities and Delete Registrations

*** Variables ***
${first_vehicle_payload_filename}                     interoperability/vehicle1-full.jsonld
${second_vehicle_payload_filename}                    interoperability/vehicle2-full.jsonld
${first_offstreet_payload_filename}                   interoperability/offstreet-parking1-full.jsonld
${second_offstreet_payload_filename}                  interoperability/offstreet-parking2-full.jsonld
${first_parking_location_name_payload_filename}       interoperability/offstreet-parking1-location-and-name.jsonld
${second_parking_location_name_payload_filename}      interoperability/offstreet-parking2-location-and-name.jsonld
${first_inclusive_registration_payload_file_path}     csourceRegistrations/interoperability/context-source-registration-inclusive-2.jsonld
${second_inclusive_registration_payload_file_path}    csourceRegistrations/interoperability/context-source-registration-inclusive-3.jsonld
${first_redirect_registration_payload_file_path}      csourceRegistrations/interoperability/context-source-registration-redirect-2.jsonld
${second_redirect_registration_payload_file_path}     csourceRegistrations/interoperability/context-source-registration-redirect-3.jsonld
${third_redirect_registration_payload_file_path}      csourceRegistrations/interoperability/context-source-registration-redirect-4.jsonld
${broker_A_url}
${broker_B_url}
${broker_C_url}
${broker_D_url}

*** Test Cases ***
IOP_003_02_02 Query Entities Of Type OffstreetParking And Vehicle with attrs
    [Documentation]    Pre-conditions: no user context. Data only on leaves. B contains OffStreetParking:1 and Vehicle:1. C contains OffStreetParking:1 with location and name only and OffStreetParking:2. D contains OffStreetParking:2 with location and name only and Vehicle:2.
    ...                Registrations established: Inclusive in A to B. Redirect in A to C. Redirect in A to D.
    [Tags]    since_v1.6.1    iop    cnf_02    4_3_3    additive-inclusive    proxy-redirect    4_3_6    5_7_2    6_4_3_1

    #Client queries all entities with type OffstreetParking and Vehicle in A and checks for a successful response that contains the location attribute for all entities.
    ${response}=    Query Entities    entity_types=OffstreetParking,Vehicle    attrs=location    broker_url=${broker_A_url}
    Check Response Status Code    200    ${response.status_code}
    &{payload}=    Evaluate    {i['id']: i for i in ${response.json()}}
    ${parking1_payload}=    Get From Dictionary    ${payload}    ${first_parking_entity_id}
    ${parking2_payload}=    Get From Dictionary    ${payload}    ${second_parking_entity_id}
    ${vehicle1_payload}=    Get From Dictionary    ${payload}    ${first_vehicle_entity_id}
    ${vehicle2_payload}=    Get From Dictionary    ${payload}    ${second_vehicle_entity_id}
    Should Contain    ${parking1_payload}    location
    Should Contain    ${parking2_payload}    location
    Should Contain    ${vehicle1_payload}    location
    Should Contain    ${vehicle2_payload}    location

    #Client queries all entities with type OffstreetParking and Vehicle in B, C and D. 
    ${response}=    Query Entities    entity_types=OffstreetParking,Vehicle    attrs=location    broker_url=${broker_B_url}
    &{first_expected_payload}=    Evaluate    {i['id']: i for i in ${response.json()}}
    ${response}=    Query Entities    entity_types=OffstreetParking,Vehicle    attrs=location    broker_url=${broker_C_url}
    &{second_expected_payload}=    Evaluate    {i['id']: i for i in ${response.json()}}
    ${response}=    Query Entities    entity_types=OffstreetParking,Vehicle    attrs=location    broker_url=${broker_D_url}
    &{third_expected_payload}=    Evaluate    {i['id']: i for i in ${response.json()}}

    #Client checks that the attributes of the entities in A are the same as the ones in B, C and D.
    ${expected_vehicle1}=    Get From Dictionary    ${first_expected_payload}    ${first_vehicle_entity_id}
    ${expected_parking1}=    Get From Dictionary    ${second_expected_payload}    ${first_parking_entity_id}
    ${expected_vehicle2}=    Get From Dictionary    ${third_expected_payload}    ${second_vehicle_entity_id}
    ${expected_parking2}=    Get From Dictionary    ${third_expected_payload}    ${second_parking_entity_id}
    Should Be Equal    ${vehicle1_payload}    ${expected_vehicle1}
    Should Be Equal    ${parking1_payload}    ${expected_parking1}
    Should Be Equal    ${vehicle2_payload}    ${expected_vehicle2}
    Should Be Equal    ${parking2_payload}    ${expected_parking2}

*** Keywords ***
Setup Initial Context Source Registrations

    ${first_parking_entity_id}=    Generate Random Parking Entity Id
    Set Suite Variable    ${first_parking_entity_id}
    ${second_parking_entity_id}=    Generate Random Parking Entity Id
    Set Suite Variable    ${second_parking_entity_id}
    ${first_vehicle_entity_id}=    Generate Random Vehicle Entity Id
    Set Suite Variable    ${first_vehicle_entity_id}
    ${second_vehicle_entity_id}=    Generate Random Vehicle Entity Id
    Set Suite Variable    ${second_vehicle_entity_id}

    ${response}=    Create Entity    ${first_vehicle_payload_filename}    ${first_vehicle_entity_id}    broker_url=${broker_B_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${first_offstreet_payload_filename}    ${first_parking_entity_id}    broker_url=${broker_B_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${first_parking_location_name_payload_filename}    ${first_parking_entity_id}    broker_url=${broker_C_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${second_offstreet_payload_filename}    ${second_parking_entity_id}    broker_url=${broker_C_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${second_parking_location_name_payload_filename}    ${second_parking_entity_id}    broker_url=${broker_D_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${second_vehicle_payload_filename}    ${second_vehicle_entity_id}    broker_url=${broker_D_url}
    Check Response Status Code    201    ${response.status_code}

    @{first_set}=    Create List
    ...    ${first_parking_entity_id}
    ...    ${first_inclusive_registration_payload_file_path}
    ...    inclusive
    ...    ${broker_B_url}
    ...    ${broker_A_url}

    @{second_set}=    Create List
    ...    ${first_vehicle_entity_id}
    ...    ${second_inclusive_registration_payload_file_path}
    ...    inclusive
    ...    ${broker_B_url}
    ...    ${broker_A_url}

    @{third_set}=    Create List
    ...    ${first_parking_entity_id}
    ...    ${first_redirect_registration_payload_file_path}
    ...    redirect
    ...    ${broker_C_url}
    ...    ${broker_A_url}

    @{fourth_set}=    Create List
    ...    ${second_parking_entity_id}
    ...    ${second_redirect_registration_payload_file_path}
    ...    redirect
    ...    ${broker_D_url}
    ...    ${broker_A_url}

    @{fifth_set}=    Create List
    ...    ${second_vehicle_entity_id}
    ...    ${third_redirect_registration_payload_file_path}
    ...    redirect
    ...    ${broker_D_url}
    ...    ${broker_A_url}

    @{second_configuration}=    Create List    ${first_set}    ${second_set}    ${third_set}    ${fourth_set}    ${fifth_set}
    Compose IOP Configuration    ${second_configuration}

Delete Entities And Delete Registrations
    @{broker_count}=    Create List    ${broker_A_url}    ${broker_B_url}    ${broker_C_url}    ${broker_D_url}
    @{entities_to_delete}=    Create List    ${first_parking_entity_id}    ${second_parking_entity_id}    ${first_vehicle_entity_id}    ${second_vehicle_entity_id}
    Delete Registrations And Entities    ${broker_count}    ${entities_to_delete}