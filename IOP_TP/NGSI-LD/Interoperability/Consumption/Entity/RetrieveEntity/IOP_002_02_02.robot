*** Settings ***
Documentation       Four brokers are set up A, B, C and D. A has three registrations, one inclusive for the entity created in B, one redirect for the entity created in C and one redirect for the entity created in D.
...                 Check that the entity returned from C has the same location attribute found in A.

Resource            ${EXECDIR}/resources/IOPUtils/InteroperabilityUtils.resource

Test Setup          Setup Initial Context Source Registrations
Test Teardown       Delete Entities and Delete Registrations

*** Variables ***
${entity_payload_filename}                     interoperability/offstreet-parking1-location-and-name.jsonld
${first_full_entity_payload_filename}          interoperability/offstreet-parking1-full.jsonld
${second_full_entity_payload_filename}         interoperability/offstreet-parking2-full.jsonld
${inclusive_registration_payload_file_path}    csourceRegistrations/interoperability/context-source-registration-inclusive-2.jsonld
${redirect_registration_payload_file_path}     csourceRegistrations/interoperability/context-source-registration-redirect-2.jsonld
${broker_A_url}
${broker_B_url}
${broker_C_url}
${broker_D_url}

*** Test Cases ***
IOP_002_02_02 Retrieve OffStreetParking:1 Location Attribute
    [Documentation]    Pre-conditions: no user context. Data only on leaves. B contains OffStreetParking:1. C contains OffStreetParking:1 with location and name only. D contains OffStreetParking:2.
    ...                Registrations established: Inclusive in A to B. Redirect in A to C. Redirect in A to D.
    [Tags]    since_v1.6.1    iop    cnf_02    4_3_3    additive-inclusive    proxy-redirect    4_3_6    5_7_1

    #Client retrieves OffStreetParking:1 in A and checks for a partial successful. The entity returned should contain the location attribute.
    ${response}=    Retrieve Entity    ${entity_id}    broker_url=${broker_A_url}
    Check Response Status Code    207    ${response.status_code}
    ${payload}=    Set To Dictionary    ${response.json()}
    Should Contain    ${payload}    location

    #Client retrieves OffStreetParking:1 in C with local=true.
    ${response}=    Retrieve Entity    ${entity_id}    broker_url=${broker_C_url}    local=true
    ${expected_payload}=    Set To Dictionary    ${response.json()}

    #Client checks that the location attribute in C is the same as the one in A.
    Should Be Equal    ${payload}[location][value]    ${expected_payload}[location][value]

*** Keywords ***
Setup Initial Context Source Registrations

    ${entity_id}=    Generate Random Parking Entity Id
    Set Suite Variable    ${entity_id}
    ${response}=    Create Entity    ${first_full_entity_payload_filename}    ${entity_id}    broker_url=${broker_B_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${entity_payload_filename}    ${entity_id}    broker_url=${broker_C_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${second_full_entity_payload_filename}    ${entity_id}    broker_url=${broker_D_url}
    Check Response Status Code    201    ${response.status_code}

    @{first_set}=    Create List
    ...    ${entity_id}
    ...    ${inclusive_registration_payload_file_path}
    ...    inclusive
    ...    ${broker_B_url}
    ...    ${broker_A_url}

    @{second_set}=    Create List
    ...    ${entity_id}
    ...    ${redirect_registration_payload_file_path}
    ...    redirect
    ...    ${broker_C_url}
    ...    ${broker_A_url}

    @{third_set}=    Create List
    ...    ${entity_id}
    ...    ${redirect_registration_payload_file_path}
    ...    redirect
    ...    ${broker_D_url}
    ...    ${broker_A_url}

    @{second_configuration}=    Create List    ${first_set}    ${second_set}    ${third_set}
    Compose IOP Configuration    ${second_configuration}

Delete Entities And Delete Registrations
    @{broker_count}=    Create List    ${broker_A_url}    ${broker_B_url}    ${broker_C_url}    ${broker_D_url}
    @{entities_to_delete}=    Create List    ${entity_id}
    Delete Registrations And Entities    ${broker_count}    ${entities_to_delete}