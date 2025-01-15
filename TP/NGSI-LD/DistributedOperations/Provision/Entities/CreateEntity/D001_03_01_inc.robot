*** Settings ***
Documentation        Verify that, when one has an entity and an inclusive registration on a Context Broker, one is able to create that entity on a Context Source from the Context Broker but gets an error for the Context Broker

Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistration.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceDiscovery.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup         Setup Entity On Local And Registration
Test Teardown      Delete Created Entities And Registration


*** Variables ***
${entity_id_prefix}                     urn:ngsi-ld:Vehicle:
${entity_payload_filename}              vehicle-simple-attributes.jsonld
${registration_id_prefix}               urn:ngsi-ld:Registration:
${registration_payload_file_path}       csourceRegistrations/context-source-registration-vehicle-redirection-ops.jsonld

*** Test Cases ***
D001_03_01_inc Create entity already existing locally on a Context Source
    [Tags]    since_v1.6.1    dist-ops    4_3_3    cf_06    additive-inclusive    4_3_6_2    5_6_1    6_3_3
    [Documentation]    Check that if one requests the Context Broker to create an entity that matches an inclusive registration and already exists locally, this raises an error on the Context Broker but is created correctly on the Context Source
    ${response}=    Create Entity    ${entity_payload_filename}    ${entity_id}
    Check Response Status Code    207    ${response.status_code}
    
    Check JSON Value In Response Body    ['status']    409    ${response.json()['errors'][0]['error']}

    @{entities_id}=    Create List    ${entity_id}
    ${response_query_remote}=    Query Entities    entity_types=Vehicle    base_url=${remote_url}
    Check Response Body Containing Entities URIS set to    ${entities_id}    ${response_query_remote.json()}


*** Keywords ***
Setup Entity On Local And Registration
    ${entity_id}=    Generate Random Entity Id    ${entity_id_prefix}
    Set Suite Variable    ${entity_id}
    ${response}=    Create Entity    ${entity_payload_filename}    ${entity_id}
    Check Response Status Code    201    ${response.status_code}

    ${registration_id}=    Generate Random Entity Id    ${registration_id_prefix}
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
    

    