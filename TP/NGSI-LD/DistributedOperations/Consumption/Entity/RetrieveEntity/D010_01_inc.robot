*** Settings ***
Documentation        Verify that, when one has an inclusive registration on a Context Broker and an entity only on a Context Source, if one retrieves entity from the Context Broker the request gets forwarded to the Context Source correctly

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
${entity_id_prefix}                       urn:ngsi-ld:Vehicle:
${entity_payload_filename}                vehicle-simple-attributes.json
${registration_id_prefix}                 urn:ngsi-ld:Registration:
${registration_payload_file_path}         csourceRegistrations/context-source-registration-vehicle-complete.jsonld

*** Test Cases ***
D010_01_inc Retrieve entity on a Context Source from the Context Broker
    [Documentation]    Check that if one retrieves entity living on a Context Source from a Context Broker, entity gets returned
    [Tags]    since_v1.6.1    dist-ops    4_3_3    cf_06    additive-inclusive    4_3_6_2    5_7_1

    ${entity_body}=    Load Entity    ${entity_payload_filename}    ${entity_id}
    Set Stub Reply    GET    /ngsi-ld/v1/entities/${entity_id}    200    ${entity_body}
    ${response}=    Retrieve Entity By Id    ${entity_id}    context=${ngsild_test_suite_context}

    Wait for redirected request

    ${stub_count}=    Get Stub Count    GET    /ngsi-ld/v1/entities/${entity_id}
    Should Be True    ${stub_count} > 0
    
    Check Response Status Code    200    ${response.status_code}

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
    ${response1}=    Create Context Source Registration With Return    ${registration_payload}
    Check Response Status Code    201    ${response1.status_code}
    Start Context Source Mock Server



Delete Created Entity And Registration
    Delete Context Source Registration    ${registration_id}
    # Delete Entity By Id    ${entity_id}    base_url=${remote_url}
    Stop Context Source Mock Server    