*** Settings ***
Documentation       Four brokers are set up b1, b2, b3 and b4. b1 has three registrations, one inclusive for the entities in b2, one redirect for the entity in b3 and one redirect for the entities in b4.
...                 Check that the entity is created in b1 and does not contain the location attribute. Check that the entity is created in b2 and does not contain the location and name properties. Check that the entity is created in b3 and b4 containing only the location attribute.

Resource            ${EXECDIR}/resources/IOPUtils/InteroperabilityUtils.resource

Test Teardown       Delete Entities and Delete Registrations
Test Template       Run Interoperability Scenario


*** Variables ***
${entity_payload_filename}                              interoperability/full-version-of-OffStreetParking2.jsonld
${inclusive_registration_payload_file_path}             csourceRegistrations/interoperability/context-source-registration-inclusive-2.jsonld
${first_redirect_registration_payload_file_path}        csourceRegistrations/interoperability/context-source-registration-redirect-2.jsonld
${second_redirect_registration_payload_file_path}       csourceRegistrations/interoperability/context-source-registration-redirect-3.jsonld
${b1_url}                                               ${EMPTY}
${b2_url}                                               ${EMPTY}
${b3_url}                                               ${EMPTY}
${b4_url}                                               ${EMPTY}


*** Test Cases ***
IOP_001_02_02_01 Create OffStreetParking:2 With Default Context
    [Tags]
    ...    since_v1.6.1
    ...    iop
    ...    cnf_02
    ...    4_3_3
    ...    additive-inclusive
    ...    proxy-redirect
    ...    4_3_6
    ...    5_6_1
    ...    default-context
    [Setup]    Setup Initial Context Source Registrations    ${core_context}
    ${core_context}
IOP_001_02_02_02 Create OffStreetParking:2 With User Context
    [Tags]
    ...    since_v1.6.1
    ...    iop
    ...    cnf_02
    ...    4_3_3
    ...    additive-inclusive
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
    Remove From Dictionary    ${expected_payload}    location

    # Agent checks (with local=true) that the Entity was created in b1 and that the Entity does not contain the "location" Property
    ${response}=    Retrieve Entity
    ...    ${entity_id}
    ...    local=true
    ...    broker_url=${b1_url}
    ...    context=${context}
    Check Response Status Code    200    ${response.status_code}
    Check Resource Set To    ${expected_payload}    ${response.json()}

    # Agent checks (with local=true) that the Entity was created in b2 and that the Entity does not contain the "location" and "name" Properties
    ${response}=    Retrieve Entity
    ...    ${entity_id}
    ...    local=true
    ...    broker_url=${b2_url}
    ...    context=${context}
    Check Response Status Code    200    ${response.status_code}
    ${expected_b2_payload}=    Load Entity    ${entity_payload_filename}    ${entity_id}
    Keep In Dictionary    ${expected_b2_payload}    id    type    availableSpotsNumber    totalSpotsNumber
    Check Resource Set To    ${expected_b2_payload}    ${response.json()}

    # Agent checks (with local=true) that the Entity was created in b3 and that the Entity contains only the "location" Property
    ${response}=    Retrieve Entity
    ...    ${entity_id}
    ...    local=true
    ...    broker_url=${b3_url}
    ...    context=${context}
    Check Response Status Code    200    ${response.status_code}
    ${expected_location_payload}=    Load Entity    ${entity_payload_filename}    ${entity_id}
    Keep In Dictionary    ${expected_location_payload}    id    type    location
    Check Resource Set To    ${expected_location_payload}    ${response.json()}

    # Agent checks (with local=true) that the Entity was created in b4 and that the Entity contains only the "location" Property
    ${response}=    Retrieve Entity
    ...    ${entity_id}
    ...    local=true
    ...    broker_url=${b4_url}
    ...    context=${context}
    Check Response Status Code    200    ${response.status_code}
    Check Resource Set To    ${expected_location_payload}    ${response.json()}

Setup Initial Context Source Registrations
    [Arguments]    ${context}
    Set Test Variable    ${entity_id}    urn:ngsi-ld:OffStreetParking:2

    @{first_set}=    Create List
    ...    ${EMPTY}
    ...    ${inclusive_registration_payload_file_path}
    ...    inclusive
    ...    ${b2_url}
    ...    ${b1_url}

    @{second_set}=    Create List
    ...    ${EMPTY}
    ...    ${first_redirect_registration_payload_file_path}
    ...    redirect
    ...    ${b3_url}
    ...    ${b1_url}

    @{third_set}=    Create List
    ...    ${EMPTY}
    ...    ${second_redirect_registration_payload_file_path}
    ...    redirect
    ...    ${b4_url}
    ...    ${b1_url}

    @{second_configuration}=    Create List    ${first_set}    ${second_set}    ${third_set}
    Compose IOP Configuration    ${second_configuration}    ld_context=${context}

Delete Entities And Delete Registrations
    @{broker_count}=    Create List    ${b1_url}    ${b2_url}    ${b3_url}    ${b4_url}
    @{entities_to_delete}=    Create List    ${entity_id}
    Delete Registrations And Entities    ${broker_count}    ${entities_to_delete}
