*** Settings ***
Documentation       Three brokers are set up A, B and C. A has two registrations, one inclusive for the entities created in B and one exclusive for the entity created in C.
...                 Check that the same entity created in B and C can be returned from A.

Resource            ${EXECDIR}/resources/IOPUtils/InteroperabilityUtils.resource

Test Setup          Setup Initial Context Source Registrations
Test Teardown       Delete Entities and Delete Registrations

*** Variables ***
${first_entity_payload_filename}               interoperability/offstreet-parking1-full.jsonld
${second_entity_payload_filename}              interoperability/offstreet-parking2-full.jsonld
${inclusive_registration_payload_file_path}    csourceRegistrations/interoperability/context-source-registration-inclusive-2.jsonld
${exclusive_registration_payload_file_path}    csourceRegistrations/interoperability/context-source-registration-exclusive-2.jsonld
${broker_A_url}
${broker_B_url}
${broker_C_url}

*** Test Cases ***
IOP_002_01_01 Retrieve OffStreetParking:1
    [Documentation]    Pre-conditions: no user context. Data only on leaves. B contains OffStreetParking:1 and OffStreetParking:2. C contains OffStreetParking:2.
    ...                Registrations established: Inclusive in A to B. Exclusive in A to C.
    [Tags]    since_v1.6.1    iop    cnf_01    4_3_3    additive-inclusive    proxy-exclusive    4_3_6    5_7_1

    #Client retrieves OffStreetParking:1 in A and checks for a successful response. 
    ${response}=    Retrieve Entity    ${entity_id1}    broker_url=${broker_A_url}
    Check Response Status Code    200    ${response.status_code}
    Should Contain   ${response.json()}    availableSpotsNumber
    Should Contain   ${response.json()}    totalSpotsNumber

    #Client retrieves OffStreetParking:1 in B.
    ${expected_payload}=    Load Entity    ${first_entity_payload_filename}    ${entity_id1}
    ${response}=    Retrieve Entity    ${entity_id1}   broker_url=${broker_B_url}
    Check Response Status Code    200    ${response.status_code}

    #Client checks that the entity returned is the full entity.
    Should Be Equal    ${response.json()}    ${expected_payload}

*** Keywords ***
Setup Initial Context Source Registrations

    ${entity_id1}=    Generate Random Parking Entity Id
    Set Suite Variable    ${entity_id1}
    ${entity_id2}=    Generate Random Parking Entity Id
    Set Suite Variable    ${entity_id2}

    ${response}=    Create Entity
    ...    ${first_entity_payload_filename}
    ...    ${entity_id1}
    ...    broker_url=${broker_B_url}
    Check Response Status Code    201    ${response.status_code}

    ${response}=    Create Entity
    ...    ${second_entity_payload_filename}
    ...    ${entity_id2}
    ...    broker_url=${broker_B_url}
    Check Response Status Code    201    ${response.status_code}

    ${response}=    Create Entity
    ...    ${second_entity_payload_filename}
    ...    ${entity_id2}
    ...    broker_url=${broker_C_url}
    Check Response Status Code    201    ${response.status_code}

    @{first_set}=    Create List
    ...    ${entity_id1}
    ...    ${inclusive_registration_payload_file_path}
    ...    inclusive
    ...    ${broker_B_url}
    ...    ${broker_A_url}

    @{second_set}=    Create List
    ...    ${entity_id2}
    ...    ${exclusive_registration_payload_file_path}
    ...    exclusive
    ...    ${broker_C_url}
    ...    ${broker_A_url}

    @{first_configuration}=    Create List    ${first_set}    ${second_set}
    Compose IOP Configuration    ${first_configuration}

Delete Entities And Delete Registrations
    @{broker_count}=    Create List    ${broker_A_url}    ${broker_B_url}    ${broker_C_url}
    @{entities_to_delete}=    Create List    ${entity_id1}    ${entity_id2}
    Delete Registrations And Entities    ${broker_count}    ${entities_to_delete}