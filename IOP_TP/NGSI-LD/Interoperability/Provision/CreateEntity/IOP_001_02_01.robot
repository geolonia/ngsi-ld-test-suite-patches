*** Settings ***
Documentation       Four brokers are set up A, B, C and D. A has three registrations, one inclusive for the entities created in B, one redirect for the entity created in C and one redirect for the entities created in D.
...                 The client creates the entity in A. The entity should not contain the location attribute in A and B. The C and D brokers should only contain the location attribute.

Resource            ${EXECDIR}/resources/IOPUtils/InteroperabilityUtils.resource

Test Setup          Setup Initial Context Source Registrations
Test Teardown       Delete Entities and Delete Registrations

*** Variables ***
${entity_payload_filename}                        interoperability/offstreet-parking1-full.jsonld
${inclusive_registration_payload_file_path}       csourceRegistrations/interoperability/context-source-registration-inclusive-2.jsonld
${redirect_registration_payload_file_path}        csourceRegistrations/interoperability/context-source-registration-redirect-2.jsonld
${broker_A_url}
${broker_B_url}
${broker_C_url}
${broker_D_url}

*** Test Cases ***
IOP_001_02_01 Create OffStreetParking:1
    [Documentation]    Pre-conditions: no user context. No data in any broker.
    ...                Registrations established: Inclusive in A to B. Redirect in A to C. Redirect in A to D.
    [Tags]    since_v1.6.1    iop    cnf_02    4_3_3    additive-inclusive    proxy-redirect    4_3_6    5_6_1

    #The agent creates the full entity of OffStreetParking:1 in A and check for a successful response
    ${response}=    Create Entity    ${entity_payload_filename}    ${entity_id}    broker_url=${broker_A_url}
    Check Response Status Code    201    ${response.status_code}
    
    #Agent checks, with local=true, that the entity is created in A and does not contain the location property
    ${response}=    Retrieve Entity    ${entity_id}    local=true    broker_url=${broker_A_url}
    Check Response Status Code    200    ${response.status_code}
    Should Not Contain    ${response.json()}    location

    #Agent checks, with local=true, that the entity is created in B and does not contain the location and name properties
    ${response}=    Retrieve Entity    ${entity_id}    local=true    broker_url=${broker_B_url}
    Check Response Status Code    200    ${response.status_code}
    Should Not Contain    ${response.json()}    location
    Should Not Contain    ${response.json()}    name

    #Agent checks, with local=true, that the entity is created in C and only contains the location property
    ${response}=    Retrieve Entity    ${entity_id}    local=true    broker_url=${broker_C_url}
    Check Response Status Code    200    ${response.status_code}
    Should Contain    ${response.json()}    location
    Should Not Contain    ${response.json()}    name
    Should Not Contain    ${response.json()}    availableSpotsNumber
    Should Not Contain    ${response.json()}    totalSpotsNumber

    #Agent checks, with local=true, that the entity is created in D and only contains the location property
    ${response}=    Retrieve Entity    ${entity_id}    local=true    broker_url=${broker_D_url}
    Check Response Status Code    200    ${response.status_code}
    Should Contain    ${response.json()}    location
    Should Not Contain    ${response.json()}    name
    Should Not Contain    ${response.json()}    availableSpotsNumber
    Should Not Contain    ${response.json()}    totalSpotsNumber

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