*** Settings ***
Documentation       Five brokers are set up A, B, C, D and E. A has two registrations, one auxiliary for the entities created in B and one inclusive for the entity created in C. B has two registration, one redirect for the entities created in D, one redirect for the entity created in E. C has one exclusive registration to E.
...                 The client creates the entity in A. The entity should be present in C and in E with only one attribute. The entity shall not be present in B and E.

Resource            ${EXECDIR}/resources/IOPUtils/InteroperabilityUtils.resource

Test Setup          Setup Initial Context Source Registrations
Test Teardown       Delete Entities and Delete Registrations

*** Variables ***
${entity_payload_filename}                             interoperability/offstreet-parking2-full.jsonld
${auxiliary_registration_payload_file_path}            csourceRegistrations/interoperability/context-source-registration-auxiliary-2.jsonld
${first_redirect_registration_payload_file_path}       csourceRegistrations/interoperability/context-source-registration-redirect-1.jsonld
${second_redirect_registration_payload_file_path}      csourceRegistrations/interoperability/context-source-registration-redirect-2.jsonld
${inclusive_registration_payload_file_path}            csourceRegistrations/interoperability/context-source-registration-inclusive-1.jsonld
${exclusive_registration_payload_file_path}            csourceRegistrations/interoperability/context-source-registration-exclusive-1.jsonld
${broker_A_url}
${broker_B_url}
${broker_C_url}
${broker_D_url}
${broker_E_url}

*** Test Cases ***
IOP_001_04_02 Create OffStreetParking:2
    [Documentation]    Pre-conditions: no user context. No data in any broker.
    ...                Registrations established: Auxiliary in A to B. Inclusive in A to C. Redirect in B to D. Redirect in B to E. Exclusive in C to E.
    [Tags]    since_v1.6.1    iop    cnf_04    4_3_3    additive-inclusive    additive-auxiliary    proxy-exclusive    proxy-redirect    4_3_6    5_6_1

    #Create the full entity of OffStreetParking:2 in A and check for a successful response
    ${response}=    Create Entity    ${entity_payload_filename}    ${entity_id}    broker_url=${broker_A_url}
    Check Response Status Code    201    ${response.status_code}

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

    #Agent checks, with local=true, that the entity is created in E and only contains the totalSpotsNumber property
    ${response}=    Retrieve Entity    ${entity_id}    local=true    broker_url=${broker_E_url}
    Check Response Status Code    200    ${response.status_code}
    Should Contain    ${response.json()}    totalSpotsNumber

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