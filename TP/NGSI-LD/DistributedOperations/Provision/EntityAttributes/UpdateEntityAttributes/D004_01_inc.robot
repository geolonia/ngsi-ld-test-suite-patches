*** Settings ***
Documentation        Verify that, when one has an inclusive registration on a Context Broker with redirectionOps, one is able to update entities on a Context Source

Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistration.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceDiscovery.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource
Resource            ${EXECDIR}/resources/MockServerUtils.resource

Test Setup         Setup Entity On Remote And Registration
Test Teardown      Delete Created Entity And Registration


*** Variables ***
${entity_id_prefix}                     urn:ngsi-ld:Vehicle:
${entity_payload_filename}              vehicle-simple-attributes.jsonld
${registration_id_prefix}               urn:ngsi-ld:Registration:
${registration_payload_file_path}       csourceRegistrations/context-source-registration-vehicle-redirection-ops.jsonld
${fragment_filename}                    vehicle-brandname-fragment.jsonld

*** Test Cases ***
D004_01_inc Query The Context Broker With Type
    [Documentation]    Check that if one request the Context Broker to update an entity that matches an inclusive registration, this is updated on the Context Source too
    [Tags]    since_v1.6.1    dist-ops    4_3_3    cf_06    additive-inclusive    4_3_6_2    5_6_2
    
    Set Stub Reply    PATCH    /ngsi-ld/v1/entities/${entity_id}/attrs/    204
    ${response}=    Update Entity Attributes    
    ...    ${entity_id}
    ...    ${fragment_filename}
    ...    ${CONTENT_TYPE_LD_JSON}
    
    Wait for redirected request
    Check Response Status Code    204    ${response.status_code}  
    ${stub_count}=    Get Stub Count    PATCH    /ngsi-ld/v1/entities/${entity_id}/attrs/
    Should Be True    ${stub_count} > 0

    ${request_payload}=    Get Request Body
    ${payload}=    Evaluate    json.loads('''${request_payload}''')    json
    Log    ${payload}
    ${request_headers}=    Get Request Headers
    Log    ${request_headers}


    @{entities_id}=    Create List    ${entity_id}
    # ${response_query_remote}=    Query Entities    entity_types=Vehicle    base_url=${remote_url}
    # Check Response Status Code    200    ${response_query_remote.status_code}
    ${payload_list}    Evaluate    [$payload]
    Check Response Body Containing Entities URIS set to    ${entities_id}    ${payload_list}


*** Keywords ***
Setup Entity On Remote And Registration
    ${entity_id}=    Generate Random Entity Id    ${entity_id_prefix}
    Set Suite Variable    ${entity_id}
    # ${response}=    Create Entity    ${entity_payload_filename}    ${entity_id}    base_url=${remote_url}
    # Check Response Status Code    201    ${response.status_code}

    ${registration_id}=    Generate Random Entity Id    ${registration_id_prefix}
    Set Suite Variable    ${registration_id}
    ${registration_payload}=    Prepare Context Source Registration From File
    ...    ${registration_id}
    ...    ${registration_payload_file_path}
    ...    entity_id=${entity_id}
    ${response1}=    Create Context Source Registration With Return    ${registration_payload}
    Check Response Status Code    201    ${response1.status_code}
    Start Context Source Mock Server


Delete Created Entity And Registration
    Delete Context Source Registration    ${registration_id} 
    # Delete Entity By Id    ${entity_id}    base_url=${remote_url}
    Stop Context Source Mock Server