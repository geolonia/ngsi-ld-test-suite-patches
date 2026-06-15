*** Settings ***
Documentation       Four brokers are set up A, B, C and D. A has three registrations, one auxiliary for the entities created in B, one inclusive for the entities created in C and one inclusive for the entity created in D.
...                 Check that queried entities returned from B, C and D match the attributes from the entities in A.
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceDiscovery.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistration.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Setup Initial Context Source Registrations
Test Teardown       Delete Entities and Delete Registrations

*** Variables ***
${first_vehicle_payload_filename}               interoperability/vehicle1-full.jsonld
${second_vehicle_payload_filename}              interoperability/vehicle2-full.jsonld
${first_full_offstreet_payload_filename}        interoperability/offstreet-parking1-full.jsonld
${second_full_offstreet_payload_filename}       interoperability/offstreet-parking2-full.jsonld
${parking_location_name_payload_filename}       interoperability/offstreet-parking1-location-and-name.jsonld
${inclusive_registration_payload_file_path}     csourceRegistrations/interoperability/context-source-registration-inclusive-1.jsonld
${auxiliary_registration_payload_file_path}     csourceRegistrations/interoperability/context-source-registration-auxiliary-3.jsonld
${b1_url}
${b2_url}
${b3_url}
${b4_url}

*** Test Cases ***
IOP_CNF_03_02 Query Entities Of Type OffstreetParking And Vehicle with attrs
    [Documentation]    Pre-conditions: No user context. Data only on leaves. B contains Vehicle:1. C contains OffStreetParking:1 with location and name only. D contains OffStreetParking:1, OffStreetParking:2 and Vehicle2.
    ...                Registrations established: Auxiliary in A to B. Inclusive in A to C. Inclusive in A to D.
    [Tags]    since_v1.6.1    iop    4_3_3    cf_06    additive-inclusive    additive-auxiliary    4_3_6    5_7_2    6_4_3_1

    #Client retrieves the location property from all entities with type OffstreetParking and Vehicle in A and checks for a successful response.
    ${response}=    Query Entities    entity_types=OffstreetParking,Vehicle    attrs=location    broker_url=${b1_url}
    Check Response Status Code    200    ${response.status_code}

    &{payload}=    Evaluate    {i['id']: i for i in ${response.json()}}
    ${first_parking_payload}=    Get From Dictionary    ${payload}    OffstreetParking:1
    ${second_parking_payload}=    Get From Dictionary    ${payload}    OffstreetParking:2
    ${first_vehicle}=    Get From Dictionary    ${payload}    Vehicle:1
    Should Contain    ${first_parking_payload}    location
    Should Contain    ${second_parking_payload}    location

    #Client queries all entities with type OffstreetParking and Vehicle in B, C and D.
    ${response}=    Query Entities    entity_types=OffstreetParking,Vehicle    attrs=location    broker_url=${b2_url}
    ${payload}=    Evaluate    {i['id']: i for i in ${response.json()}}
    ${expected_entity1}=    Get From Dictionary    ${payload}    Vehicle:1

    ${response}=    Query Entities    entity_types=OffstreetParking,Vehicle    attrs=location    broker_url=${b3_url}
    ${payload}=    Evaluate    {i['id']: i for i in ${response.json()}}
    ${expected_entity2}=    Get From Dictionary    ${payload}    OffstreetParking:1

    ${response}=    Query Entities    entity_types=OffstreetParking,Vehicle    attrs=location    broker_url=${b4_url}
    ${payload}=    Evaluate    {i['id']: i for i in ${response.json()}}
    ${expected_entity3}=    Get From Dictionary    ${payload}    OffstreetParking:1
    ${expected_entity4}=    Get From Dictionary    ${payload}    OffstreetParking:2

    #Client checks that the attributes of the entities in A are the same as the ones in B, C and D.
    Should Be Equal    ${first_parking_payload}[name]    ${expected_entity2}[name]
    Should Be Equal    ${first_parking_payload}[location]    ${expected_entity2}[location]
    Should Be Equal    ${first_parking_payload}[availableSpotsNumber]    ${expected_entity3}[availableSpotsNumber]
    Should Be Equal    ${first_parking_payload}[totalSpotsNumber]    ${expected_entity3}[totalSpotsNumber]
    Should Be Equal    ${second_parking_payload}    ${expected_entity4}
    Should Be Equal    ${first_vehicle}    ${expected_entity1}

*** Keywords ***
Setup Initial Context Source Registrations
    ${parking_entity_id1}=    Generate Random Parking Entity Id
    Set Suite Variable    ${parking_entity_id1}
    ${parking_entity_id2}=    Generate Random Parking Entity Id
    Set Suite Variable    ${parking_entity_id2}
    ${vehicle_entity_id1}=    Generate Random Vehicle Entity Id
    Set Suite Variable    ${vehicle_entity_id1}
    ${vehicle_entity_id2}=    Generate Random Vehicle Entity Id
    Set Suite Variable    ${vehicle_entity_id2}

    ${response}=    Create Entity    ${first_vehicle_payload_filename}    ${vehicle_entity_id1}    broker_url=${b2_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${parking_location_name_payload_filename}    ${parking_entity_id1}    broker_url=${b3_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${first_full_offstreet_payload_filename}    ${parking_entity_id1}    broker_url=${b4_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${second_full_offstreet_payload_filename}    ${parking_entity_id2}    broker_url=${b4_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${first_vehicle_payload_filename}    ${vehicle_entity_id2}    broker_url=${b4_url}
    Check Response Status Code    201    ${response.status_code}

    ${registration_id1}=    Generate Random CSR Id
    Set Suite Variable    ${registration_id1}
    ${registration_payload}=    Prepare Context Source Registration From File
    ...    ${registration_id1}
    ...    ${auxiliary_registration_payload_file_path}
    ...    entity_id=${vehicle_entity_id1}
    ...    endpoint=${b2_url}
    ...    mode=auxiliary
    ${response}=    Create Context Source Registration With Return    ${registration_payload}    broker_url=${b1_url}
    Check Response Status Code    201    ${response.status_code}

    ${registration_id2}=    Generate Random CSR Id
    Set Suite Variable    ${registration_id2}
    ${registration_payload}=    Prepare Context Source Registration From File
    ...    ${registration_id2}
    ...    ${inclusive_registration_payload_file_path}
    ...    entity_id=${parking_entity_id1}
    ...    endpoint=${b3_url}
    ...    mode=inclusive
    ${response}=    Create Context Source Registration With Return    ${registration_payload}    broker_url=${b1_url}
    Check Response Status Code    201    ${response.status_code}

    ${registration_id3}=    Generate Random CSR Id
    Set Suite Variable    ${registration_id3}
    ${registration_payload}=    Prepare Context Source Registration From File
    ...    ${registration_id3}
    ...    ${inclusive_registration_payload_file_path}
    ...    entity_id=${vehicle_entity_id2}
    ...    endpoint=${b4_url}
    ...    mode=inclusive
    ${response}=    Create Context Source Registration With Return    ${registration_payload}    broker_url=${b1_url}
    Check Response Status Code    201    ${response.status_code}

    ${registration_id4}=    Generate Random CSR Id
    Set Suite Variable    ${registration_id4}
    ${registration_payload}=    Prepare Context Source Registration From File
    ...    ${registration_id4}
    ...    ${inclusive_registration_payload_file_path}
    ...    entity_id=${parking_entity_id1}
    ...    endpoint=${b3_url}
    ${response}=    Create Context Source Registration With Return    ${registration_payload}    broker_url=${b1_url}
    Check Response Status Code    201    ${response.status_code}

    ${registration_id5}=    Generate Random CSR Id
    Set Suite Variable    ${registration_id5}
    ${registration_payload}=    Prepare Context Source Registration From File
    ...    ${registration_id5}
    ...    ${inclusive_registration_payload_file_path}
    ...    entity_id=${parking_entity_id2}
    ...    endpoint=${b4_url}
    ...    mode=inclusive
    ${response}=    Create Context Source Registration With Return    ${registration_payload}    broker_url=${b1_url}
    Check Response Status Code    201    ${response.status_code}

Delete Entities And Delete Registrations
    Delete Context Source Registration    ${registration_id1}    broker_url=${b1_url}
    Delete Context Source Registration    ${registration_id2}    broker_url=${b1_url}
    Delete Context Source Registration    ${registration_id3}    broker_url=${b1_url}
    Delete Context Source Registration    ${registration_id4}    broker_url=${b1_url}
    Delete Context Source Registration    ${registration_id5}    broker_url=${b1_url}
    Delete Entity    ${vehicle_entity_id1}    broker_url=${b2_url}
    Delete Entity    ${parking_entity_id1}    broker_url=${b3_url}
    Delete Entity    ${parking_entity_id1}    broker_url=${b4_url}
    Delete Entity    ${parking_entity_id2}    broker_url=${b4_url}
    Delete Entity    ${vehicle_entity_id2}    broker_url=${b4_url}