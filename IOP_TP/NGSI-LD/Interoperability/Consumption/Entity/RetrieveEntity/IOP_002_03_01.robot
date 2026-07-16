*** Settings ***
Documentation       Four brokers are set up A, B, C and D. A has three registrations, one auxiliary for the entity created in B, one inclusive for the entity created in C and one inclusive for the entity created in D.
...                 Check that a partial response was returned from A and that the entity matches the one in B and it does not contain the attribute location found in C.

Resource            ${EXECDIR}/resources/IOPUtils/InteroperabilityUtils.resource

Test Setup          Setup Initial Context Source Registrations
Test Teardown       Delete Entities and Delete Registrations

*** Variables ***
${entity_payload_filename}                            interoperability/offstreet-parking1-no-location.jsonld
${first_full_entity_payload_filename}                 interoperability/offstreet-parking1-full.jsonld
${second_full_entity_payload_filename}                interoperability/offstreet-parking2-full.jsonld
${first_inclusive_registration_payload_file_path}     csourceRegistrations/interoperability/context-source-registration-inclusive-1.jsonld
${second_inclusive_registration_payload_file_path}    csourceRegistrations/interoperability/context-source-registration-inclusive-2.jsonld
${auxiliary_registration_payload_file_path}           csourceRegistrations/interoperability/context-source-registration-auxiliary-2.jsonld
${broker_A_url}
${broker_B_url}
${broker_C_url}
${broker_D_url}

*** Test Cases ***
IOP_002_03_01 Retrieve OffStreetParking:1
    [Documentation]    Pre-conditions: no user context. Data on every broker. A contains OffStreetParking:1 without location. B contains OffStreetParking:1. C contains OffStreetParking:1 without location. D contains OffStreetParking:2.
    ...                Registrations established: Auxiliary in A to B. Inclusive in A to C. Inclusive in A to D.
    [Tags]    since_v1.6.1    iop    cnf_03    4_3_3    additive-inclusive    additive-auxiliary    4_3_6    5_7_1

    #Client retrieves OffStreetParking:1 in A and checks for a partial successful. The entity returned should not contain the location attribute.
    ${response}=    Retrieve Entity    ${entity_id}    broker_url=${broker_A_url}
    Check Response Status Code    207    ${response.status_code}
    ${payload}=    Set To Dictionary    ${response.json()}
    Should Not Contain    ${payload}    location

    #Client retrieves OffStreetParking:1 in B, C and D with the local=true flag.
    ${response}=    Retrieve Entity    ${entity_id}    broker_url=${broker_A_url}    local=true
    ${first_payload}=    Set To Dictionary    ${response.json()}
    ${response}=    Retrieve Entity    ${entity_id}    broker_url=${broker_B_url}    local=true
    ${second_payload}=    Set To Dictionary    ${response.json()}
    ${response}=    Retrieve Entity    ${entity_id}    broker_url=${broker_C_url}    local=true
    ${third_payload}=    Set To Dictionary    ${response.json()}

    #Client checks that the entity returned from A should have the same attributes as the one in B and it should not contain the attribute location found in C.
    Should Be Equal    ${payload}    ${first_payload}
    Should Not Contain    ${payload}[location]    ${second_payload}[location]

*** Keywords ***
Setup Initial Context Source Registrations

    ${entity_id}=    Generate Random Parking Entity Id
    Set Suite Variable    ${entity_id}
    ${response}=    Create Entity    ${entity_payload_filename}    ${entity_id}    broker_url=${broker_A_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${first_full_entity_payload_filename}    ${entity_id}    broker_url=${broker_B_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${entity_payload_filename}    ${entity_id}    broker_url=${broker_C_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${second_full_entity_payload_filename}    ${entity_id}    broker_url=${broker_D_url}
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