*** Settings ***
Documentation       Verify that, when one has an entity on a Context Broker and on a Context Source and an inclusive registration on the Context Broker, one is not able to create that entity on the Context Source from the Context Broker

Resource            ${EXECDIR}/resources/ApiUtils/Common.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceDiscovery.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistration.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Setup Entities And Registration
Test Teardown       Delete Created Entities And Registration


*** Variables ***
${entity_payload_filename}              vehicle-simple-attributes.jsonld
${registration_payload_file_path}       csourceRegistrations/context-source-registration-vehicle-redirection-ops.jsonld


*** Test Cases ***
D001_03_02_inc Create entity already existing on both Context Broker and Context Source
    [Documentation]    Check that if one requests the Context Broker to create an entity that matches an inclusive registration and already exists both locally and remotely, this raises an error on both Context Broker and Context Source
    [Tags]    since_v1.6.1    dist-ops    4_3_3    cf_06    additive-inclusive    4_3_6_2    5_6_1    6_3_3
    ${response}=    Create Entity    ${entity_payload_filename}    ${entity_id}
    Check Response Status Code    207    ${response.status_code}

    ${length}=    Get Length    ${response.json()['errors']}
    Should Be Equal As Integers    ${length}    2
    Should Be Empty    ${response.json()['success']}


*** Keywords ***
Setup Entities And Registration
    ${entity_id}=    Generate Random Vehicle Entity Id
    Set Suite Variable    ${entity_id}
    ${response}=    Create Entity    ${entity_payload_filename}    ${entity_id}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Create Entity    ${entity_payload_filename}    ${entity_id}    base_url=${remote_url}
    Check Response Status Code    201    ${response.status_code}

    ${registration_id}=    Generate Random CSR Id
    Set Suite Variable    ${registration_id}
    ${registration_payload}=    Prepare Context Source Registration From File
    ...    ${registration_id}
    ...    ${registration_payload_file_path}
    ...    entity_id=${entity_id}
    ${response1}=    Create Context Source Registration With Return    ${registration_payload}
    Check Response Status Code    201    ${response1.status_code}

Delete Created Entities And Registration
    Delete Context Source Registration    ${registration_id}
    Delete Entity By Id    ${entity_id}
    Delete Entity By Id    ${entity_id}    base_url=${remote_url}
