*** Settings ***
Documentation       Check that if one requests the Context Broker to merge a batch of entities, they get merged in the Context Source thanks to redirect registration

Resource            ${EXECDIR}/resources/ApiUtils/Common.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceDiscovery.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistration.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource
Resource            ${EXECDIR}/resources/MockServerUtils.resource

Test Setup          Create Entity And Registration On The Context Broker And Start Context Source Mock Server
Test Teardown       Delete Created Entity And Registration And Stop Context Source Mock Server

*** Variables ***
${entity_payload_filename}              vehicle-simple-attributes-second.jsonld
${entity_second_payload_filename}       vehicle-simple-attributes-second-different.jsonld
${entity_pattern}                       urn:ngsi-ld:Vehicle:*
${registration_payload_file_path}       csourceRegistrations/context-source-registration-vehicle-batch-ops.jsonld

*** Test Cases ***
D016_01_red Merge Batch Entities On The Context Source
    [Documentation]    Check that if one requests the Context Broker to merge a batch of entities that match an exclusive registration, they are merged on the Context Source too.
    [Tags]    since_v1.6.1    dist-ops    4_3_3    cf_06    proxy-redirect    4_3_6_3    5_6_20

    ${first_entity}=    Load Entity    ${entity_payload_filename}    ${first_entity_id}
    ${second_entity}=    Load Entity    ${entity_payload_filename}    ${second_entity_id}
    Set Stub Reply    POST    /broker1/ngsi-ld/v1/entityOperations/create    204
    Set Stub Reply    POST    /broker2/ngsi-ld/v1/entityOperations/create    204
    
    ${new_first_entity}=    Load Entity    ${entity_second_payload_filename}    ${first_entity_id}
    ${new_second_entity}=    Load Entity    ${entity_second_payload_filename}    ${second_entity_id}
    @{entities_ids_to_be_merged}=    Create List    ${first_entity_id}    ${second_entity_id}
    @{entities_to_be_merged}=    Create List    ${new_first_entity}    ${new_second_entity}

    Set Stub Reply    POST    /broker1/ngsi-ld/v1/entityOperations/merge    204
    Set Stub Reply    POST    /broker2/ngsi-ld/v1/entityOperations/merge    204
    ${response}=    Batch Merge Entities    @{entities_to_be_merged}
    Check Response Status Code    204    ${response.status_code}

    ${stub_count}=    Get Stub Count    POST    /broker1/ngsi-ld/v1/entityOperations/merge
    Should Be Equal As Integers    ${stub_count}    1
    ${stub_count}=    Get Stub Count    POST    /broker2/ngsi-ld/v1/entityOperations/merge
    Should Be Equal As Integers    ${stub_count}    1

    ${expected_entities_ids}=    Catenate    SEPARATOR=,    @{entities_ids_to_be_merged}
    ${response}=    Query Entities
    ...    entity_ids=${expected_entities_ids}
    ...    entity_types=Vehicle
    ...    context=${ngsild_test_suite_context}
    ...    accept=${CONTENT_TYPE_LD_JSON}
    
    Should Contain    ${response.json()}    speed

*** Keywords ***
Create Entity And Registration On The Context Broker And Start Context Source Mock Server
    ${first_entity_id}=    Generate Random Vehicle Entity Id
    Set Suite Variable    ${first_entity_id}
    ${second_entity_id}=    Generate Random Vehicle Entity Id
    Set Suite Variable    ${second_entity_id}

    ${registration_id}=    Generate Random CSR Id
    Set Suite Variable    ${registration_id}
    ${registration_payload}=    Prepare Context Source Registration From File
    ...    ${registration_id}
    ...    ${registration_payload_file_path}
    ...    entity_id_pattern=${entity_pattern}
    ...    mode=redirect
    ...    endpoint=/broker1
    ${response}=    Create Context Source Registration With Return    ${registration_payload}
    Check Response Status Code    201    ${response.status_code}
    ${registration_id2}=    Generate Random CSR Id
    Set Suite Variable    ${registration_id2}
    ${registration_payload}=    Prepare Context Source Registration From File
    ...    ${registration_id2}
    ...    ${registration_payload_file_path}
    ...    entity_id_pattern=${entity_pattern}
    ...    mode=redirect
    ...    endpoint=/broker2
    ${response}=    Create Context Source Registration With Return    ${registration_payload}
    Check Response Status Code    201    ${response.status_code}

    Start Context Source Mock Server

Delete Created Entity And Registration And Stop Context Source Mock Server
    @{entities_ids_to_be_deleted}=    Create List    ${first_entity_id}    ${second_entity_id}
    Batch Delete Entities    entities_ids_to_be_deleted=@{entities_ids_to_be_deleted}
    Delete Context Source Registration    ${registration_id}
    Delete Context Source Registration    ${registration_id2}
    Stop Context Source Mock Server
