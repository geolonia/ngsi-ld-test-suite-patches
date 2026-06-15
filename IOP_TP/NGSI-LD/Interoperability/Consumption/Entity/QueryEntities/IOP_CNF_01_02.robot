*** Settings ***
Documentation       Three brokers are set up A, B and C. A has two registrations, one inclusive for the entities created in B and one exclusive for the entity created in C. 
...                 The client sends and HTTP POST request to check that the entities can be queried from all brokers.

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceDiscovery.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistration.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Setup Initial Context Source Registrations
Test Teardown       Delete Entities and Delete Registrations

*** Variables ***
${first_entity_payload_filename}               interoperability/offstreet-parking1-full.jsonld
${second_entity_payload_filename}              interoperability/offstreet-parking2-full.jsonld
${third_entity_payload_filename}               interoperability/offstreet-parking2-no-location-and-totalspotsnumber.jsonld
${inclusive_registration_payload_file_path}    csourceRegistrations/interoperability/context-source-registration-inclusive-2.jsonld
${exclusive_registration_payload_file_path}    csourceRegistrations/interoperability/context-source-registration-exclusive-2.jsonld
${b1_url}
${b2_url}
${b3_url}

*** Test Cases ***
IOP_CNF_01_01 Query Entities Of Type OffstreetParking Via POST
    [Documentation]    Pre-conditions: no user context. Data only on leaves. B contains OffStreetParking1 and OffStreetParking2 without location and totalSpotsNumber. C contains OffStreetParking2.
    ...                Registrations established: Inclusive in A to B. Exclusive in A to C.
    [Tags]    since_v1.6.1    iop    4_3_3    cf_06    additive-inclusive    proxy-exclusive    4_3_6    5_7_2    6_23_2_1

    #Agent queries all entities with type OffstreetParking in A and checks for a successful response that contains the attributes of both entities in B and C.
    @{entities}=    Create List    ${entity_id}    ${second_entity_id}
    ${response}=    Query Entities Via POST   entities=${entities}    broker_url=${b1_url}
    Check Response Status Code    200    ${response.status_code}
    @{payload}=    Set Variable   ${response.json()}
    Should Contain    ${payload}\[OffstreetParking1]    availableSpotsNumber
    Should Contain    ${payload}\[OffstreetParking1]    totalSpotsNumber
    Should Contain    ${payload}\[OffstreetParking2]    availableSpotsNumber
    Should Contain    ${payload}\[OffstreetParking2]    location

    #Agent queries all entities with type OffstreetParking in B and C
    ${response}=    Query Entities Via POST   entities=${entities}    broker_url=${b2_url}
    @{first_expected_payload}=    Set Variable    ${response.json()}
    Check Response Body Containing Entities URIS set to    ${entities}    ${response.json()}

    ${response}=    Query Entities Via POST   entities=${entity_id}    broker_url=${b3_url}
    @{second_expected_payload}=    Set Variable    ${response.json()}
    Check Response Body Containing Entities URIS set to    ${entity_id}    ${response.json()}

    #Agent checks that OffstreetParking1 in A is the same as the one in B and that OffstreetParking2 in A contains the attributes of both OffstreetParking2 in B and C.
    Should Be Equal    ${payload}\[OffstreetParking1]    ${first_expected_payload}\[OffstreetParking1]
    Should Contain    ${payload}\[OffstreetParking2]    ${first_expected_payload}\[OffstreetParking2][totalSpotsNumber]
    Should Contain    ${payload}\[OffstreetParking2]    ${second_expected_payload}\[OffstreetParking2][location]

*** Keywords ***
Setup Initial Context Source Registrations
    ${entity_id}=    Generate Random Parking Entity Id
    Set Suite Variable    ${entity_id}
    ${second_entity_id}=    Generate Random Parking Entity Id
    Set Suite Variable    ${second_entity_id}
    ${response}=    Create Entity    ${first_entity_payload_filename}    ${entity_id}    broker_url=${b2_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${third_entity_payload_filename}    ${second_entity_id}    broker_url=${b2_url}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${second_entity_payload_filename}    ${entity_id}    broker_url=${b3_url}
    Check Response Status Code    201    ${response.status_code}

    ${registration_id1}=     Generate Random CSR Id
    Set Suite Variable    ${registration_id1}
    ${registration_payload}=    Prepare Context Source Registration From File
    ...    ${registration_id1}
    ...    ${inclusive_registration_payload_file_path}
    ...    entity_id=${entity_id}
    ...    broker_url=${b2_url}
    ...    mode=inclusive
    ${response}=    Create Context Source Registration With Return    ${registration_payload}    broker_url=${b1_url}
    Check Response Status Code    201    ${response.status_code}

    ${registration_id2}=     Generate Random CSR Id
    Set Suite Variable    ${registration_id2}
    ${registration_payload}=    Prepare Context Source Registration From File
    ...    ${registration_id2}
    ...    ${inclusive_registration_payload_file_path}
    ...    entity_id=${second_entity_id}
    ...    broker_url=${b2_url}
    ...    mode=inclusive
    ${response}=    Create Context Source Registration With Return    ${registration_payload}    broker_url=${b1_url}
    Check Response Status Code    201    ${response.status_code}

    ${registration_id3}=     Generate Random CSR Id
    Set Suite Variable    ${registration_id3}
    ${registration_payload}=    Prepare Context Source Registration From File
    ...    ${registration_id3}
    ...    ${exclusive_registration_payload_file_path}
    ...    entity_id=${entity_id}
    ...    broker_url=${b3_url}
    ...    mode=exclusive
    ${response}=    Create Context Source Registration With Return    ${registration_payload}    broker_url=${b1_url}
    Check Response Status Code    201    ${response.status_code}

Delete Entities And Delete Registrations
    Delete Context Source Registration    ${registration_id1}    broker_url=${b1_url}
    Delete Context Source Registration    ${registration_id2}    broker_url=${b1_url}
    Delete Context Source Registration    ${registration_id3}    broker_url=${b1_url}
    Delete Entity    ${entity_id}    broker_url=${b2_url}
    Delete Entity    ${second_entity_id}    broker_url=${b2_url}
    Delete Entity    ${entity_id}    broker_url=${b3_url}