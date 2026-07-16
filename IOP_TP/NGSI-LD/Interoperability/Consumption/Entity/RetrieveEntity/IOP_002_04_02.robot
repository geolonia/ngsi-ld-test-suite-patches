*** Settings ***
Documentation       Five brokers are set up A, B, C, D and E. A has two registrations, one auxiliary for the entity created in B, one inclusive for the entity created in C. B has two registrations, one redirect for the entity created in D and one redirect for the entity created in E. C shall establish one exclusive registration to E.
...                 Check that the entity returned from A match the attributes from the entity in B, C and E.

Resource            ${EXECDIR}/resources/IOPUtils/InteroperabilityUtils.resource

Test Setup          Setup Initial Context Source Registrations
Test Teardown       Delete Entities and Delete Registrations

*** Variables ***
${no_location_entity_payload_filename}              interoperability/offstreet-parking1-no-location.jsonld
${location_name_entity_payload_filename}            interoperability/offstreet-parking1-location-and-name.jsonld
${full_entity_payload_filename}                     interoperability/offstreet-parking1-full.jsonld
${inclusive_registration_payload_file_path}         csourceRegistrations/interoperability/context-source-registration-inclusive-1.jsonld
${auxiliary_registration_payload_file_path}         csourceRegistrations/interoperability/context-source-registration-auxiliary-1.jsonld
${exclusive_registration_payload_file_path}         csourceRegistrations/interoperability/context-source-registration-exclusive-3.jsonld
${first_redirect_registration_payload_file_path}    csourceRegistrations/interoperability/context-source-registration-redirect-2.jsonld
${second_redirect_registration_payload_file_path}   csourceRegistrations/interoperability/context-source-registration-redirect-3.jsonld
${broker_A_url}
${broker_B_url}
${broker_C_url}
${broker_D_url}
${broker_E_url}

*** Test Cases ***
IOP_002_04_02 Retrieve OffStreetParking:1 Location Attribute
    [Documentation]    Pre-conditions: no user context. Data on every broker. A contains OffStreetParking:1 without location. B contains OffStreetParking:1 without location. C contains OffStreetParking:1 without location. D contains OffStreetParking:1. E contains OffStreetParking:1 with location and name only.
    ...                Registrations established: Auxiliary in A to B. Inclusive in A to C. Redirect in B to D. Redirect in B to E. Exclusive in C to E.
    [Tags]    since_v1.6.1    iop    cnf_04    4_3_3    additive-inclusive    additive-auxiliary    proxy-redirect    proxy-exclusive    4_3_6    5_7_1

    #Client retrieves OffStreetParking:1 in A and checks for a successful response.
    ${response}=    Retrieve Entity    ${entity_id}    broker_url=${broker_A_url}
    Check Response Status Code    200    ${response.status_code}
    ${payload}=    Set To Dictionary    ${response.json()}
    Should Contain    ${payload}    location

    #Client retrieves OffStreetParking:1 in B, C and E with local=true.
    ${response}=    Retrieve Entity    ${entity_id}    broker_url=${broker_B_url}    local=true
    ${first_expected_payload}=    Set To Dictionary    ${response.json()}
    ${response}=    Retrieve Entity    ${entity_id}    broker_url=${broker_C_url}    local=true
    ${second_expected_payload}=    Set To Dictionary    ${response.json()}
    ${response}=    Retrieve Entity    ${entity_id}    broker_url=${broker_E_url}    local=true
    ${third_expected_payload}=    Set To Dictionary    ${response.json()}

    #Client checks that the entity returned from A should have the same attributes as the one in B, C and E.
    Should Be Equal    ${payload}[availableSpotsNumbers]    ${first_expected_payload}[availableSpotsNumbers]
    Should Be Equal    ${payload}[totalSpotsNumber]    ${first_expected_payload}[totalSpotsNumber]
    Should Be Equal    ${payload}[location]    ${second_expected_payload}[location]
    Should Be Equal    ${payload}[name]    ${third_expected_payload}[name]

*** Keywords ***
Setup Initial Context Source Registrations

    ${entity_id}=    Generate Random Parking Entity Id
    Set Suite Variable    ${entity_id}
    ${response}=    Create Entity    ${no_location_entity_payload_filename}    ${entity_id}    broker_url=${broker_A_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${no_location_entity_payload_filename}    ${entity_id}    broker_url=${broker_B_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${no_location_entity_payload_filename}    ${entity_id}    broker_url=${broker_C_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${full_entity_payload_filename}    ${entity_id}    broker_url=${broker_D_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${location_name_entity_payload_filename}    ${entity_id}    broker_url=${broker_E_url}
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
    ...    ${entity_id}
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
    ...    ${entity_id}
    ...    ${exclusive_registration_payload_file_path}
    ...    exclusive
    ...    ${broker_E_url}
    ...    ${broker_C_url}
    
    @{fourth_configuration}=    Create List    ${first_set}    ${second_set}    ${third_set}    ${fourth_set}    ${fifth_set}
    Compose IOP Configuration    ${fourth_configuration}

Delete Entities And Delete Registrations
    @{broker_count}=    Create List    ${broker_A_url}    ${broker_B_url}    ${broker_C_url}    ${broker_D_url}    ${broker_E_url}
    @{entities_to_delete}=    Create List    ${entity_id}
    Delete Registrations And Entities    ${broker_count}    ${entities_to_delete}