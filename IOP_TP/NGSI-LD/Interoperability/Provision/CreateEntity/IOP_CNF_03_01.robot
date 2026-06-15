*** Settings ***
Documentation       Four brokers are set up A, B, C and D. A has three registrations, one auxiliary for the entities created in B, one inclusive for the entity created in C and one inclusive for the entities created in D.
...                 The client creates the entity in A. The entity should be present in A and B, should not be present in C and should only contain some attributes in D.

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceDiscovery.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistration.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Setup Initial Context Source Registrations
Test Teardown       Delete Entities and Delete Registrations

*** Variables ***
${entity_payload_filename}                              interoperability/offstreet-parking1-full.jsonld
${auxiliary_registration_payload_file_path}             csourceRegistrations/interoperability/context-source-registration-auxiliary-2.jsonld
${first_inclusive_registration_payload_file_path}       csourceRegistrations/interoperability/context-source-registration-inclusive-1.jsonld
${second_inclusive_registration_payload_file_path}      csourceRegistrations/interoperability/context-source-registration-inclusive-2.jsonld
${b1_url}
${b2_url}
${b3_url}
${b4_url}
*** Test Cases ***
IOP_CNF_03_01 Create OffStreetParking:1
    [Documentation]    Pre-conditions: No user context. No data in any broker.
    ...                Registrations established: Auxiliary in A to B. Inclusive in A to C. Inclusive in A to D.
    [Tags]    since_v1.6.1    iop    4_3_3    cf_06    additive-inclusive    additive-auxiliary    4_3_6    5_6_1

    #Agent checks that the full entity of OffStreetParking:1 is created in A and check for a successful response
    ${response}=    Create Entity    ${entity_payload_filename}    ${entity_id}    broker_url=${b1_url}
    Check Response Status Code    201    ${response.status_code}
    Should Contain    ${response.json()}    name
    Should Contain    ${response.json()}    location
    Should Contain    ${response.json()}    availableSpotsNumber
    Should Contain    ${response.json()}    totalSpotsNumber

    #Agent checks, with local=true, that the entity is created in A
    ${response}=    Retrieve Entity    ${entity_id}    local=true    broker_url=${b1_url}
    Should Be Equal    ${response.json()}    ${entity_payload_filename}
    Check Response Status Code    200    ${response.status_code}

    #Agent checks, with local=true, that the entity was not created in B
    ${response}=    Retrieve Entity    ${entity_id}    local=true    broker_url=${b2_url}
    Check Response Status Code    404    ${response.status_code}

    #Agent checks, with local=true, that the entity is created in C
    ${response}=    Retrieve Entity    ${entity_id}    local=true    broker_url=${b3_url}
    Check Response Status Code    200    ${response.status_code}
    Should Be Equal    ${response.json()}    ${entity_payload_filename}

    #Agent checks, with local=true, that the entity is created in D and only contains the properties availableSpotsNumber and totalSpotsNumber
    ${response}=    Retrieve Entity    ${entity_id}    local=true    broker_url=${b4_url}
    Check Response Status Code    200    ${response.status_code}
    Should Contain    ${response.json()}    availableSpotsNumber
    Should Contain    ${response.json()}    totalSpotsNumber
    Should Not Contain    ${response.json()}    name
    Should Not Contain    ${response.json()}    location

*** Keywords ***
Setup Initial Context Source Registrations
    ${entity_id}=    Generate Random Parking Entity Id
    Set Suite Variable    ${entity_id}
    
    ${registration_id1}=     Generate Random CSR Id
    Set Suite Variable    ${registration_id1}
    ${registration_payload}=    Prepare Context Source Registration From File
    ...    ${registration_id1}
    ...    ${auxiliary_registration_payload_file_path}
    ...    entity_id=${entity_id}
    ...    broker_url=${b2_url}
    ...    mode=auxiliary
    ${response}=    Create Context Source Registration With Return    ${registration_payload}    broker_url=${b1_url}
    Check Response Status Code    201    ${response.status_code}

    ${registration_id2}=     Generate Random CSR Id
    Set Suite Variable    ${registration_id2}
    ${registration_payload}=    Prepare Context Source Registration From File
    ...    ${registration_id2}
    ...    ${first_inclusive_registration_payload_file_path}
    ...    entity_id=${entity_id}
    ...    broker_url=${b3_url}
    ...    mode=inclusive
    ${response}=    Create Context Source Registration With Return    ${registration_payload}    broker_url=${b1_url}
    Check Response Status Code    201    ${response.status_code}

    ${registration_id3}=     Generate Random CSR Id
    Set Suite Variable    ${registration_id3}
    ${registration_payload}=    Prepare Context Source Registration From File
    ...    ${registration_id3}
    ...    ${second_inclusive_registration_payload_file_path}
    ...    entity_id=${entity_id}
    ...    broker_url=${b4_url}
    ...    mode=inclusive
    ${response}=    Create Context Source Registration With Return    ${registration_payload}    broker_url=${b1_url}
    Check Response Status Code    201    ${response.status_code}

Delete Entities And Delete Registrations
    Delete Context Source Registration    ${registration_id1}    broker_url=${b1_url}
    Delete Context Source Registration    ${registration_id2}    broker_url=${b1_url}
    Delete Context Source Registration    ${registration_id3}    broker_url=${b1_url}
    Delete Entity    ${entity_id}    broker_url=${b1_url}