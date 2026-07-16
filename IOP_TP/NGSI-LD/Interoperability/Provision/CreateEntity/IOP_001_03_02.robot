*** Settings ***
Documentation       Four brokers are set up A, B, C and D. A has three registrations, one auxiliary for the entities created in B, one inclusive for the entity created in C and one inclusive for the entities created in D.
...                 The client creates the entity in A. The entity should be present in C, should not be present in both B and D.

Resource            ${EXECDIR}/resources/IOPUtils/InteroperabilityUtils.resource

Test Setup          Setup Initial Context Source Registrations
Test Teardown       Delete Entities and Delete Registrations

*** Variables ***
${entity_payload_filename}                              interoperability/offstreet-parking1-location-and-name.jsonld
${auxiliary_registration_payload_file_path}             csourceRegistrations/interoperability/context-source-registration-auxiliary-2.jsonld
${first_inclusive_registration_payload_file_path}       csourceRegistrations/interoperability/context-source-registration-inclusive-1.jsonld
${second_inclusive_registration_payload_file_path}      csourceRegistrations/interoperability/context-source-registration-inclusive-2.jsonld
${broker_A_url}
${broker_B_url}
${broker_C_url}
${broker_D_url}

*** Test Cases ***
IOP_001_03_02 Create Partial OffStreetParking:1
    [Documentation]    Pre-conditions: no user context. No data in any broker.
    ...                Registrations established: Auxiliary in A to B. Inclusive in A to C. Inclusive in A to D.
    [Tags]    since_v1.6.1    iop    cnf_03    4_3_3    additive-inclusive    additive-auxiliary    4_3_6    5_6_1

    #Check that the the entity of OffStreetParking:1 with location and name only is created in A and check for a successful response
    ${response}=    Create Entity    ${entity_payload_filename}    ${entity_id}    broker_url=${broker_A_url}
    Check Response Status Code    201    ${response.status_code}
    Should Contain    ${response.json()}    name
    Should Contain    ${response.json()}    location

    #Agent checks, with local=true, that the entity is created in A
    ${response}=    Retrieve Entity    ${entity_id}    local=true    broker_url=${broker_A_url}
    Check Response Status Code    200    ${response.status_code}
    #Agent checks, with local=true, that the entity was not created in B
    ${response}=    Retrieve Entity    ${entity_id}    local=true    broker_url=${broker_B_url}
    Check Response Status Code    404    ${response.status_code}
    #Agent checks, with local=true, that the entity is created in C
    ${response}=    Retrieve Entity    ${entity_id}    local=true    broker_url=${broker_C_url}
    Check Response Status Code    200    ${response.status_code}
    #Agent checks, with local=true, that the entity was not created in D
    ${response}=    Retrieve Entity    ${entity_id}    local=true    broker_url=${broker_D_url}
    Check Response Status Code    404    ${response.status_code}

*** Keywords ***
Setup Initial Context Source Registrations

    ${entity_id}=    Generate Random Parking Entity Id
    Set Suite Variable    ${entity_id}

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