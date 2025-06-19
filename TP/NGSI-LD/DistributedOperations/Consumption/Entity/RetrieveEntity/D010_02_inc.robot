*** Settings ***
Documentation       Verify that, when one has an inclusive registration on a Context Broker and an entity only on a Context Source, if one retrieves entity from the Context Broker with local flag entity not found error is raised

Resource            ${EXECDIR}/resources/ApiUtils/Common.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceDiscovery.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistration.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Setup Entity On Remote And Registration
Test Teardown       Delete Created Entity And Registration


*** Variables ***
${entity_payload_filename}              vehicle-simple-attributes.jsonld
${registration_payload_file_path}       csourceRegistrations/context-source-registration-vehicle-complete.jsonld


*** Test Cases ***
D010_02_inc Retrieve entity on a Context Source from the Context Broker with local flag
    [Documentation]    Check that if one retrieves entity living on a Context Source from a Context Broker with local flag, entity not found error is raised
    [Tags]    since_v1.6.1    dist-ops    4_3_3    cf_06    additive-inclusive    4_3_6_2    5_7_1    6_3_18
    ${response}=    Retrieve Entity By Id    ${entity_id}    context=${ngsild_test_suite_context}    local=true
    Check Response Status Code    404    ${response.status_code}


*** Keywords ***
Setup Entity On Remote And Registration
    ${entity_id}=    Generate Random Vehicle Entity Id
    Set Suite Variable    ${entity_id}
    ${response}=    Create Entity    ${entity_payload_filename}    ${entity_id}    base_url=${remote_url}
    Check Response Status Code    201    ${response.status_code}

    ${registration_id}=    Generate Random CSR Id
    Set Suite Variable    ${registration_id}
    ${registration_payload}=    Prepare Context Source Registration From File
    ...    ${registration_id}
    ...    ${registration_payload_file_path}
    ${response1}=    Create Context Source Registration With Return    ${registration_payload}
    Check Response Status Code    201    ${response1.status_code}

Delete Created Entity And Registration
    Delete Entity By Id    ${entity_id}    base_url=${remote_url}
    Delete Context Source Registration    ${registration_id}
