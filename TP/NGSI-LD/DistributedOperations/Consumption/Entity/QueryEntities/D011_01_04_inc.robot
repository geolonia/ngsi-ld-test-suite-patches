*** Settings ***
Documentation       Verify that, when one has an inclusive registration on a Context Broker, one entity on it and another on a Context Source, if one queries the Context Broker the query gets forwarded to the Context Source correctly

Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistration.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceDiscovery.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource
Resource            ${EXECDIR}/resources/MockServerUtils.resource

Test Setup         Create Entity And Registration On The Context Broker And Start Context Source Mock Server
Test Teardown      Delete Created Entity And Registration And Stop Context Source Mock Server

*** Variables ***
${entity_id_prefix}                     urn:ngsi-ld:Vehicle:
${entity_payload_filename}              vehicle-simple-attributes.json
${entity_payload_filename2}             vehicle-simple-attributes-second.jsonld
${registration_id_prefix}               urn:ngsi-ld:Registration:
${registration_payload_file_path}       csourceRegistrations/context-source-registration-vehicle-complete.jsonld


*** Test Cases ***
D011_01_04_inc Query The Context Broker With Type and Attribute In Neither
    [Documentation]    Check that if one queries for attribute present in neither of the entities, neither of them gets returned
    [Tags]    since_v1.6.1    dist-ops    4_3_3    cf_06    additive-inclusive    4_3_6_2    5_7_2
    ${entity_body}=    Load Entity    ${entity_payload_filename}    ${first_entity_id}
    Set Stub Reply    GET   /ngsi-ld/v1/entities?type=Vehicle   200    ${entity_body}
    
    ${response}=    Query Entities    entity_types=Vehicle    attrs=speed    context=${ngsild_test_suite_context}
    Check Response Status Code    200    ${response.status_code}
    Should Be Empty    ${response.json()}


*** Keywords ***
Create Entity And Registration On The Context Broker And Start Context Source Mock Server
    ${first_entity_id}=    Generate Random Entity Id    ${entity_id_prefix}
    Set Suite Variable    ${first_entity_id}

    ${second_entity_id}=    Generate Random Entity Id    ${entity_id_prefix}
    Set Suite Variable    ${second_entity_id}
    ${response1}=    Create Entity    ${entity_payload_filename2}    ${second_entity_id}
    Check Response Status Code    201    ${response1.status_code}

    ${registration_id}=    Generate Random Entity Id    ${registration_id_prefix}
    Set Suite Variable    ${registration_id}
    ${registration_payload}=    Prepare Context Source Registration From File
    ...    ${registration_id}
    ...    ${registration_payload_file_path}
    ${response2}=    Create Context Source Registration With Return    ${registration_payload}
    Check Response Status Code    201    ${response2.status_code}
    Start Context Source Mock Server



Delete Created Entity And Registration And Stop Context Source Mock Server
    Delete Context Source Registration    ${registration_id} 
    Delete Entity By Id    ${second_entity_id} 
    Stop Context Source Mock Server
