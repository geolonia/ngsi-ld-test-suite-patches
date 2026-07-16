*** Settings ***
Documentation       Three brokers are set up A, B and C. A has two registrations, one inclusive for the entities created in B and one exclusive for the entity created in C.
...                 Check that the entity is created in A and B but not in C.

Resource            ${EXECDIR}/resources/IOPUtils/InteroperabilityUtils.resource

Test Setup          Setup Initial Context Source Registrations
Test Teardown       Delete Entities and Delete Registrations

*** Variables ***
${entity_payload_filename}                        interoperability/offstreet-parking1-full.jsonld
${inclusive_registration_payload_file_path}       csourceRegistrations/interoperability/context-source-registration-inclusive-2.jsonld
${exclusive_registration_payload_file_path}       csourceRegistrations/interoperability/context-source-registration-exclusive-2.jsonld
${broker_A_url}
${broker_B_url}
${broker_C_url}

*** Test Cases ***
IOP_001_01_01 Create OffStreetParking:1
    [Documentation]    Pre-conditions: no user context. No data in any broker.
    ...                Registrations established: Inclusive in A to B. Exclusive in A to C.
    [Tags]    since_v1.6.1    iop    cnf_01    4_3_3    additive-inclusive    proxy-exclusive    4_3_6    5_6_1

    #Create OffStreetParking:1 in A and check for a successful response
    ${expected_payload}=    Load Entity    ${entity_payload_filename}    ${entity_id}
    ${response}=    Create Entity    ${entity_payload_filename}    ${entity_id}    broker_url=${broker_A_url}
    Check Response Status Code    201    ${response.status_code}

    #Agent checks, with local=true, that the entity is created in A
    ${response}=    Retrieve Entity    ${entity_id}    local=true    broker_url=${broker_A_url}
    Check Response Status Code    200    ${response.status_code}
    Should Be Equal    ${response.json()}    ${expected_payload}

    #Agent checks, with local=true, that the entity is created in B and only contains the attributes availableSpotsNumber and totalSpotsNumber
    ${response}=    Retrieve Entity    ${entity_id}    local=true    broker_url=${broker_B_url}
    Check Response Status Code    200    ${response.status_code}
    Should Contain    ${response.json()}    availableSpotsNumber
    Should Contain    ${response.json()}    totalSpotsNumber
    Should Not Contain    ${response.json()}    name
    Should Not Contain    ${response.json()}    location

    #Agent checks, with local=true, that the entity is not created in C
    ${response}=    Retrieve Entity    ${entity_id}    local=true    broker_url=${broker_C_url}
    Check Response Status Code    404    ${response.status_code}

*** Keywords ***
Setup Initial Context Source Registrations

    ${entity_id}=    Generate Random Parking Entity Id
    Set Suite Variable    ${entity_id}

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