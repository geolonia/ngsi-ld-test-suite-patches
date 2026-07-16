*** Settings ***
Documentation       Four brokers are set up A, B, C and D. A has three registrations, one inclusive for the entities created in B, one redirect for the entities created in C and D and one redirect for the entity created in D.
...                 The client sends a HTTP GET request to check that quering the offparking type returns the entities in B, C and D and said entities have the same attributes as the ones queried from A.

Resource            ${EXECDIR}/resources/IOPUtils/InteroperabilityUtils.resource

Test Setup          Setup Initial Context Source Registrations
Test Teardown       Delete Entities and Delete Registrations

*** Variables ***
${location_name_payload_filename}                     interoperability/offstreet-parking2-location-and-name.jsonld
${first_entity_no_location_payload_filename}          interoperability/offstreet-parking1-no-location.jsonld
${second_entity_no_location_payload_filename}         interoperability/offstreet-parking2-no-location.jsonld
${first_full_entity_payload_filename}                 interoperability/offstreet-parking1-full.jsonld
${second_full_entity_payload_filename}                interoperability/offstreet-parking2-full.jsonld
${inclusive_registration_payload_file_path}           csourceRegistrations/interoperability/context-source-registration-inclusive-2.jsonld
${first_redirect_registration_payload_file_path}      csourceRegistrations/interoperability/context-source-registration-redirect-2.jsonld
${second_redirect_registration_payload_file_path}     csourceRegistrations/interoperability/context-source-registration-redirect-3.jsonld
${broker_A_url}
${broker_B_url}
${broker_C_url}
${broker_D_url}

*** Test Cases ***
IOP_003_02_01 Query Entities Of Type OffstreetParking Via GET
    [Documentation]    Pre-conditions: no user context. Data on every broker. B contains OffStreetParking:1 without location and OffStreetParking:2 without location. C contains OffStreetParking:1 and OffStreetParking:2. D contains OffStreetParking:2 with location and name only.
    ...                Registrations established: Inclusive in A to B. Redirect in A to C. Redirect in A to D.
    [Tags]    since_v1.6.1    iop    cnf_02    4_3_3    additive-inclusive    proxy-redirect    4_3_6    5_7_2    6_4_3_1

    #Agent queries all entities with type OffstreetParking in A and checks for a successful response not containing the name attribute.
    ${response}=    Query Entities    entity_types=OffstreetParking    broker_url=${broker_A_url}
    Check Response Status Code    200    ${response.status_code}
    @{entities_A}=    Set Variable   ${response.json()}
    ${first_payload}=    Get From List   ${entities_A}    0
    ${second_payload}=    Get From List   ${entities_A}    1
    Should Not Contain    ${first_payload}   name
    Should Not Contain    ${second_payload}    name

    #Agent queries all entities with type OffstreetParking in B, C and D
    ${response}=    Query Entities    entity_types=OffstreetParking    broker_url=${broker_B_url}
    @{entities_B}=    Set Variable    ${response.json()}
    ${first_B_payload}=    Get From List   ${entities_B}    0
    ${second_B_payload}=    Get From List   ${entities_B}    1

    ${response}=    Query Entities    entity_types=OffstreetParking    broker_url=${broker_C_url}
    @{entities_C}=    Set Variable    ${response.json()}
    ${C_payload}=    Get From List   ${entities_C}    0

    ${response}=    Query Entities    entity_types=OffstreetParking    broker_url=${broker_D_url}
    @{entities_D}=    Set Variable    ${response.json()}
    ${D_payload}=    Get From List   ${entities_D}    0
    
    #Agent checks that OffstreetParking:1 in A has the same availableSpotsNumber and totalSpotsNumber as the one in B and the same location attribute found in C. The OffstreetParking:2 entity in A contains the attributes of both OffstreetParking:2 availableSpotsNumber and totalSpotsNumber in C and the same location found in D.
    Should Be Equal    ${first_payload}[availableSpotsNumber]    ${first_b2_payload}[availableSpotsNumber]
    Should Be Equal    ${first_payload}[totalSpotsNumber]    ${first_b2_payload}[totalSpotsNumber]
    Should Be Equal    ${first_payload}[location]    ${b3_payload}[location]

    Should Be Equal    ${second_payload}[availableSpotsNumber]    ${second_B_payload}[availableSpotsNumber]
    Should Be Equal    ${second_payload}[totalSpotsNumber]    ${second_B_payload}[totalSpotsNumber]
    Should Be Equal    ${second_payload}[location]    ${D_payload}[location]

*** Keywords ***
Setup Initial Context Source Registrations

    ${entity_id}=    Generate Random Parking Entity Id
    Set Suite Variable    ${entity_id}
    ${second_entity_id}=    Generate Random Parking Entity Id
    Set Suite Variable    ${second_entity_id}

    ${response}=    Create Entity    ${first_entity_no_location_payload_filename}    ${entity_id}    broker_url=${broker_B_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${second_entity_no_location_payload_filename}    ${second_entity_id}    broker_url=${broker_B_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${first_full_entity_payload_filename}    ${entity_id}    broker_url=${broker_C_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${second_full_entity_payload_filename}    ${second_entity_id}    broker_url=${broker_C_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${location_name_payload_filename}    ${entity_id}    broker_url=${broker_D_url}
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
    ...    ${broker_C_url}
    ...    ${broker_A_url}

    @{third_set}=    Create List
    ...    ${entity_id}
    ...    ${first_redirect_registration_payload_file_path}
    ...    redirect
    ...    ${broker_C_url}
    ...    ${broker_A_url}

    @{fourth_set}=    Create List
    ...    ${entity_id}
    ...    ${first_redirect_registration_payload_file_path}
    ...    redirect
    ...    ${broker_C_url}
    ...    ${broker_A_url}

    @{fifth_set}=    Create List
    ...    ${entity_id}
    ...    ${second_redirect_registration_payload_file_path}
    ...    redirect
    ...    ${broker_D_url}
    ...    ${broker_A_url}

    @{second_configuration}=    Create List    ${first_set}    ${second_set}    ${third_set}    ${fourth_set}    ${fifth_set}
    Compose IOP Configuration    ${second_configuration}

Delete Entities And Delete Registrations
    @{broker_count}=    Create List    ${broker_A_url}    ${broker_B_url}    ${broker_C_url}    ${broker_D_url}
    @{entities_to_delete}=    Create List    ${entity_id}    ${second_entity_id}
    Delete Registrations And Entities    ${broker_count}    ${entities_to_delete}