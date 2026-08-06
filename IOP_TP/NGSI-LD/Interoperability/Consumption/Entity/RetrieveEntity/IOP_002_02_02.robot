*** Settings ***
Documentation       Four brokers are set up b1, b2, b3 and b4. b1 has three registrations, one inclusive for the entity in b2, one redirect for the entity in b3 and one redirect for the entity in b4.
...                 Check that the OffStreetParking:1 entity returned from b1 has location attribute. Check that the location attribute from the entity returned from b1 is the same as the one returned from b3.

Resource            ${EXECDIR}/resources/IOPUtils/InteroperabilityUtils.resource

Test Teardown       Delete Entities and Delete Registrations
Test Template       Run Interoperability Scenario


*** Variables ***
${entity_payload_filename}                      interoperability/offStreetParking1-with-location-and-name-only.jsonld
${first_full_entity_payload_filename}           interoperability/full-version-of-OffStreetParking1.jsonld
${second_full_entity_payload_filename}          interoperability/full-version-of-OffStreetParking2.jsonld
${inclusive_registration_payload_file_path}     csourceRegistrations/interoperability/context-source-registration-inclusive-2.jsonld
${redirect_registration_payload_file_path}      csourceRegistrations/interoperability/context-source-registration-redirect-2.jsonld
${b1_url}                                       ${EMPTY}
${b2_url}                                       ${EMPTY}
${b3_url}                                       ${EMPTY}
${b4_url}                                       ${EMPTY}


*** Test Cases ***
IOP_002_02_02_01 Retrieve OffStreetParking:1 Location Attribute With Default Context
    [Tags]
    ...    since_v1.6.1
    ...    iop
    ...    cnf_02
    ...    4_3_3
    ...    additive-inclusive
    ...    proxy-redirect
    ...    4_3_6
    ...    5_7_1
    ...    default-context
    [Setup]    Setup Initial Context Source Registrations    ${core_context}
    ${core_context}
IOP_002_02_02_02 Retrieve OffStreetParking:1 Location Attribute With User Context
    [Tags]
    ...    since_v1.6.1
    ...    iop
    ...    cnf_02
    ...    4_3_3
    ...    additive-inclusive
    ...    proxy-redirect
    ...    4_3_6
    ...    5_7_1
    ...    user-context
    [Setup]    Setup Initial Context Source Registrations    ${ngsild_test_suite_context}
    ${ngsild_test_suite_context}


*** Keywords ***
Run Interoperability Scenario
    [Arguments]    ${context}

    # Client sends an HTTP GET request to b1 to retrieve the "location" Property from the Entity OffStreetParking:1
    ${response_b1}=    Retrieve Entity
    ...    ${first_entity_id}
    ...    attrs=location
    ...    context=${context}
    ...    broker_url=${b1_url}
    ...    type=OffStreetParking

    # Agent checks that a partial success response has been returned and that OffStreetParking:1 with the "location" Property was returned
    Check Response Status Code    200    ${response_b1.status_code}

    # Client sends an HTTP GET request (with local=true) to b3 to retrieve the Entity OffStreetParking:1
    ${response_b3}=    Retrieve Entity
    ...    ${first_entity_id}
    ...    local=true
    ...    context=${context}
    ...    broker_url=${b3_url}
    ...    type=OffStreetParking
    Check Response Status Code    200    ${response_b3.status_code}
    ${expected_b3}=    Load Entity    ${entity_payload_filename}    ${first_entity_id}
    Check Resource Set To    ${expected_b3}    ${response_b3.json()}

    # Agent checks that the Entity returned in step (2) contains the attribute "location" and that it matches the one from the Entity returned in step (3)
    ${expected_b1}=    Load Entity    ${entity_payload_filename}    ${first_entity_id}
    Keep In Dictionary    ${expected_b1}    id    type    location
    Set To Dictionary    ${expected_b1}    location=${response_b3.json()}[location]
    Check Resource Set To    ${expected_b1}    ${response_b1.json()}

Setup Initial Context Source Registrations
    [Arguments]    ${context}
    Set Test Variable    ${first_entity_id}    urn:ngsi-ld:OffStreetParking:1
    Set Test Variable    ${second_entity_id}    urn:ngsi-ld:OffStreetParking:2
    ${response}=    Create Entity
    ...    ${first_full_entity_payload_filename}
    ...    ${first_entity_id}
    ...    broker_url=${b2_url}
    ...    context=${context}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity
    ...    ${entity_payload_filename}
    ...    ${first_entity_id}
    ...    broker_url=${b3_url}
    ...    context=${context}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity
    ...    ${second_full_entity_payload_filename}
    ...    ${second_entity_id}
    ...    broker_url=${b4_url}
    ...    context=${context}
    Check Response Status Code    201    ${response.status_code}

    @{first_set}=    Create List
    ...    ${EMPTY}
    ...    ${inclusive_registration_payload_file_path}
    ...    inclusive
    ...    ${b2_url}
    ...    ${b1_url}

    @{second_set}=    Create List
    ...    ${EMPTY}
    ...    ${redirect_registration_payload_file_path}
    ...    redirect
    ...    ${b3_url}
    ...    ${b1_url}

    @{third_set}=    Create List
    ...    ${EMPTY}
    ...    ${redirect_registration_payload_file_path}
    ...    redirect
    ...    ${b4_url}
    ...    ${b1_url}

    @{second_configuration}=    Create List    ${first_set}    ${second_set}    ${third_set}
    Compose IOP Configuration    ${second_configuration}    ld_context=${context}

Delete Entities And Delete Registrations
    @{broker_count}=    Create List    ${b1_url}    ${b2_url}    ${b3_url}    ${b4_url}
    @{entities_to_delete}=    Create List    ${first_entity_id}    ${second_entity_id}
    Delete Registrations And Entities    ${broker_count}    ${entities_to_delete}
