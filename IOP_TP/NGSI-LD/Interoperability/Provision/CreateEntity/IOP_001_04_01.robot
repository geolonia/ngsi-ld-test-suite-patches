*** Settings ***
Documentation       Five brokers are set up b1, b2, b3, b4 and b5. b1 has two registrations, one auxiliary for the entities in b2 and one inclusive for the entity in b3. b2 has two registration, one redirect for the entities in b4, one redirect for the entity in b5. b3 has one exclusive registration to b5.
...                 Check that the entity is created in b1 and b3. The entity shall not be created in b2, b4 and b5.

Resource            ${EXECDIR}/resources/IOPUtils/InteroperabilityUtils.resource

Test Teardown       Delete Entities and Delete Registrations
Test Template       Run Interoperability Scenario


*** Variables ***
${entity_payload_filename}                              interoperability/full-version-of-OffStreetParking1.jsonld
${auxiliary_registration_payload_file_path}             csourceRegistrations/interoperability/context-source-registration-auxiliary-2.jsonld
${first_redirect_registration_payload_file_path}        csourceRegistrations/interoperability/context-source-registration-redirect-1.jsonld
${second_redirect_registration_payload_file_path}       csourceRegistrations/interoperability/context-source-registration-redirect-2.jsonld
${inclusive_registration_payload_file_path}             csourceRegistrations/interoperability/context-source-registration-inclusive-1.jsonld
${exclusive_registration_payload_file_path}             csourceRegistrations/interoperability/context-source-registration-exclusive-1.jsonld
${b1_url}                                               ${EMPTY}
${b2_url}                                               ${EMPTY}
${b3_url}                                               ${EMPTY}
${b4_url}                                               ${EMPTY}
${b5_url}                                               ${EMPTY}


*** Test Cases ***
IOP_001_04_01_01 Create OffStreetParking:1 With Default Context
    [Tags]
    ...    since_v1.6.1
    ...    iop
    ...    cnf_04
    ...    4_3_3
    ...    additive-inclusive
    ...    additive-auxiliary
    ...    proxy-exclusive
    ...    proxy-redirect
    ...    4_3_6
    ...    5_6_1
    ...    default-context
    [Setup]    Setup Initial Context Source Registrations    ${core_context}
    ${core_context}
IOP_001_04_01_02 Create OffStreetParking:1 With User Context
    [Tags]
    ...    since_v1.6.1
    ...    iop
    ...    cnf_04
    ...    4_3_3
    ...    additive-inclusive
    ...    additive-auxiliary
    ...    proxy-exclusive
    ...    proxy-redirect
    ...    4_3_6
    ...    5_6_1
    ...    user-context
    [Setup]    Setup Initial Context Source Registrations    ${ngsild_test_suite_context}
    ${ngsild_test_suite_context}


*** Keywords ***
Run Interoperability Scenario
    [Arguments]    ${context}

    # Client sends an HTTP POST request to b1 to create the entity ${entity_payload_filename}
    ${response}=    Create Entity
    ...    ${entity_payload_filename}
    ...    ${entity_id}
    ...    broker_url=${b1_url}
    ...    context=${context}

    # Agent checks that a success response has been returned
    Check Response Status Code    201    ${response.status_code}

    ${expected_payload}=    Load Entity    ${entity_payload_filename}    ${entity_id}

    # Agent checks (with local=true) that the Entity was created in b1
    ${response}=    Retrieve Entity
    ...    ${entity_id}
    ...    local=true
    ...    broker_url=${b1_url}
    ...    context=${context}
    Check Response Status Code    200    ${response.status_code}
    Check Resource Set To    ${expected_payload}    ${response.json()}
    # Agent checks (with local=true) that the Entity was NOT created in b2
    ${response}=    Retrieve Entity
    ...    ${entity_id}
    ...    local=true
    ...    broker_url=${b2_url}
    ...    context=${context}
    Check Response Status Code    404    ${response.status_code}
    # Agent checks (with local=true) that the Entity was created in b3
    ${response}=    Retrieve Entity
    ...    ${entity_id}
    ...    local=true
    ...    broker_url=${b3_url}
    ...    context=${context}
    Check Response Status Code    200    ${response.status_code}
    Check Resource Set To    ${expected_payload}    ${response.json()}
    # Agent checks (with local=true) that the Entity was NOT created in b4
    ${response}=    Retrieve Entity
    ...    ${entity_id}
    ...    local=true
    ...    broker_url=${b4_url}
    ...    context=${context}
    Check Response Status Code    404    ${response.status_code}
    # Agent checks (with local=true) that the Entity was NOT created in b5
    ${response}=    Retrieve Entity
    ...    ${entity_id}
    ...    local=true
    ...    broker_url=${b5_url}
    ...    context=${context}
    Check Response Status Code    404    ${response.status_code}

Setup Initial Context Source Registrations
    [Arguments]    ${context}
    Set Test Variable    ${entity_id}    urn:ngsi-ld:OffStreetParking:1

    @{first_set}=    Create List
    ...    ${EMPTY}
    ...    ${auxiliary_registration_payload_file_path}
    ...    auxiliary
    ...    ${b2_url}
    ...    ${b1_url}

    @{second_set}=    Create List
    ...    ${EMPTY}
    ...    ${first_redirect_registration_payload_file_path}
    ...    redirect
    ...    ${b4_url}
    ...    ${b2_url}

    @{third_set}=    Create List
    ...    ${EMPTY}
    ...    ${second_redirect_registration_payload_file_path}
    ...    redirect
    ...    ${b5_url}
    ...    ${b2_url}

    @{fourth_set}=    Create List
    ...    ${EMPTY}
    ...    ${inclusive_registration_payload_file_path}
    ...    inclusive
    ...    ${b3_url}
    ...    ${b1_url}

    @{fifth_set}=    Create List
    ...    ${EMPTY}
    ...    ${exclusive_registration_payload_file_path}
    ...    exclusive
    ...    ${b5_url}
    ...    ${b3_url}

    @{fourth_configuration}=    Create List
    ...    ${first_set}
    ...    ${second_set}
    ...    ${third_set}
    ...    ${fourth_set}
    ...    ${fifth_set}
    Compose IOP Configuration    ${fourth_configuration}    ld_context=${context}

Delete Entities And Delete Registrations
    @{broker_count}=    Create List
    ...    ${b1_url}
    ...    ${b2_url}
    ...    ${b3_url}
    ...    ${b4_url}
    ...    ${b5_url}
    @{entities_to_delete}=    Create List    ${entity_id}
    Delete Registrations And Entities    ${broker_count}    ${entities_to_delete}
