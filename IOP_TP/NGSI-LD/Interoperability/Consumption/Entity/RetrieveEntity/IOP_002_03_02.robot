*** Settings ***
Documentation       Four brokers are set up A, B, C and D. A has three registrations, one auxiliary for the entity created in B, one inclusive for the entity created in C and one inclusive for the entity created in D.
...                 Check the entity returned from A contains the location property and said attribute is the same as the one returned from C.

Resource            ${EXECDIR}/resources/IOPUtils/InteroperabilityUtils.resource

Test Setup          Setup Initial Context Source Registrations
Test Teardown       Delete Entities and Delete Registrations

*** Variables ***
${no_location_entity_payload_filename}                interoperability/offstreet-parking1-no-location.jsonld
${location_name_entity_payload_filename}              interoperability/offstreet-parking1-location-and-name.jsonld
${full_entity_payload_filename}                       interoperability/offstreet-parking1-full.jsonld
${first_inclusive_registration_payload_file_path}     csourceRegistrations/interoperability/context-source-registration-inclusive-1.jsonld
${second_inclusive_registration_payload_file_path}    csourceRegistrations/interoperability/context-source-registration-inclusive-2.jsonld
${auxiliary_registration_payload_file_path}           csourceRegistrations/interoperability/context-source-registration-auxiliary-2.jsonld
${broker_A_url}
${broker_B_url}
${broker_C_url}
${broker_D_url}

*** Test Cases ***
IOP_002_03_02 Retrieve OffStreetParking:1 Location Attribute
    [Documentation]    Pre-conditions: no user context. Data on every broker. A contains OffStreetParking:1 without location. B contains OffStreetParking:1. C contains OffStreetParking:1 with location and name only. D contains OffStreetParking:1 without location.
    ...                Registrations established: Auxiliary in A to B. Inclusive in A to C. Inclusive in A to D.
    [Tags]    since_v1.6.1    iop    cnf_03    4_3_3    additive-inclusive    additive-auxiliary    4_3_6    5_7_1

    #Client retrieves OffStreetParking:1 in A and checks for a partial successful. The entity returned should only contain the location attribute.
    ${response}=    Retrieve Entity    ${entity_id}    broker_url=${broker_A_url}
    Check Response Status Code    207    ${response.status_code}
    ${payload}=    Set To Dictionary    ${response.json()}
    Should Contain    ${payload}    location

    #Client retrieves OffStreetParking:1 in C with local=true.
    ${response}=    Retrieve Entity    ${entity_id}    broker_url=${broker_C_url}    local=true
    ${expected_payload}=    Set To Dictionary    ${response.json()}

    #Client checks that the location attribute in A is the same as the one in C.
    Should Be Equal    ${payload}[location][value]    ${expected_payload}[location][value]

*** Keywords ***
Setup Initial Context Source Registrations

    ${entity_id}=    Generate Random Parking Entity Id
    Set Suite Variable    ${entity_id}
    ${response}=    Create Entity    ${no_location_entity_payload_filename}    ${entity_id}    broker_url=${broker_A_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${full_entity_payload_filename}    ${entity_id}    broker_url=${broker_B_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${location_name_entity_payload_filename}    ${entity_id}    broker_url=${broker_C_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${no_location_entity_payload_filename}    ${entity_id}    broker_url=${broker_D_url}
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