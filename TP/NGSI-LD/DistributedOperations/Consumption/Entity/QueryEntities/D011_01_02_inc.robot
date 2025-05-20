*** Settings ***
Documentation       Verify that, when one has an inclusive registration on a Context Broker and an entity only on a Context Source, if one queries the Context Broker the query gets forwarded to the Context Source correctly

Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistration.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceDiscovery.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Setup Entity On Remote And Registration
Test Teardown       Delete Created Entity And Registration


*** Variables ***
${entity_id_prefix}                     urn:ngsi-ld:Vehicle:
${entity_payload_filename}              vehicle-simple-attributes.jsonld
${registration_id_prefix}               urn:ngsi-ld:Registration:
${registration_payload_file_path}       csourceRegistrations/context-source-registration-vehicle-complete.jsonld


*** Test Cases ***
D011_01_02_inc Query The Context Broker With Type And Missing Attribute
    [Documentation]    Check that if one queries for type and an attribute that is missing, no entity gets returned
    [Tags]    since_v1.6.1    dist-ops    4_3_3    cf_06    additive-inclusive    4_3_6_2    5_7_2
    ${response}=    Query Entities    entity_types=Vehicle    attrs=speed    context=${ngsild_test_suite_context}
    Check Response Status Code    200    ${response.status_code}
    Should Be Empty    ${response.json()}


*** Keywords ***
Setup Entity On Remote And Registration
    ${entity_id}=    Generate Random Entity Id    ${entity_id_prefix}
    Set Suite Variable    ${entity_id}
    ${response}=    Create Entity    ${entity_payload_filename}    ${entity_id}    base_url=${remote_url}
    Check Response Status Code    201    ${response.status_code}

    ${registration_id}=    Generate Random Entity Id    ${registration_id_prefix}
    Set Suite Variable    ${registration_id}
    ${registration_payload}=    Prepare Context Source Registration From File
    ...    ${registration_id}
    ...    ${registration_payload_file_path}
    ${response1}=    Create Context Source Registration With Return    ${registration_payload}
    Check Response Status Code    201    ${response1.status_code}

Delete Created Entity And Registration
    Delete Entity By Id    ${entity_id}    base_url=${remote_url}
    Delete Context Source Registration    ${registration_id}
