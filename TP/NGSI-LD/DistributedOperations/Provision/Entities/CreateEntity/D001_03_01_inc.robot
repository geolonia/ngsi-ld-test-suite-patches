*** Settings ***
Documentation        Verify that, when one has an entity and an inclusive registration on a Context Broker, one is able to create that entity on a Context Source from the Context Broker but gets an error for the Context Broker

Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistration.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceDiscovery.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource
Resource            ${EXECDIR}/resources/MockServerUtils.resource

Test Setup         Setup Entity On Local And Registration
Test Teardown      Delete Created Entities And Registration


*** Variables ***
${entity_id_prefix}                     urn:ngsi-ld:Vehicle:
${entity_payload_filename}              vehicle-simple-attributes.jsonld
${registration_id_prefix}               urn:ngsi-ld:Registration:
${registration_payload_file_path}       csourceRegistrations/context-source-registration-vehicle-redirection-ops.jsonld

*** Test Cases ***
D001_03_01_inc Create entity already existing locally on a Context Source
    [Documentation]    Check that if one requests the Context Broker to create an entity that matches an inclusive registration and already exists locally, this raises an error on the Context Broker but is created correctly on the Context Source
    [Tags]    since_v1.6.1    dist-ops    4_3_3    cf_06    additive-inclusive    4_3_6_2    5_6_1    6_3_3

    Set Stub Reply    POST    /ngsi-ld/v1/entities    201
    ${response}=    Create Entity    ${entity_payload_filename}    ${entity_id}
    Check Response Status Code    207    ${response.status_code}
    
    Check JSON Value In Response Body    ['status']    409    ${response.json()['errors'][0]['error']}
    ${length}=    Get Length    ${response.json()['errors']}
    Should Be Equal As Integers    ${length}    1

    Wait for redirected request

    ${request_payload}=    Get Request Body
    ${payload}=    Evaluate    json.loads('''${request_payload}''')    json
    Log    ${payload}
    ${request_headers}=    Get Request Headers
    Log    ${request_headers}

    @{entities_id}=    Create List    ${entity_id}
    ${payload_list}    Evaluate    [$payload]
    Check Response Body Containing Entities URIS set to    ${entities_id}    ${payload_list}

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
    Start Context Source Mock Server

Delete Created Entities And Registration
    Delete Context Source Registration    ${registration_id}
    Delete Entity By Id    ${entity_id}
    Stop Context Source Mock Server