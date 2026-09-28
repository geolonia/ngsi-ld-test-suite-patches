*** Settings ***
Documentation       Verify that, when one has an exclusive registration on a Context Broker, one is able to replace a target entity attribute and the change is forwarded to the Context Source

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
${entity_payload_filename}              vehicle-simple-different-attributes.jsonld
${entity_attribute_filename}            fragmentEntities/vehicle-speed-two-datasetid-05-fragment.json
${registration_payload_file_path}       csourceRegistrations/context-source-registration-vehicle-speed-with-redirection-ops.jsonld
${attribute_name}                       speed

*** Test Cases ***
D009_01_exc Replace Entity Attribute
    [Documentation]    Check that one can replace an existing entity attribute, the changes will be forwarded to the Context Source thanks to an exclusive registration
    [Tags]    since_v1.6.1    dist-ops    4_3_3    cf_04    proxy-exclusive    4_3_6_3    5_6_19    6_3_18

    Set Stub Reply    POST    /broker1/ngsi-ld/v1/entities   201
    ${response}=    Create Entity    ${entity_payload_filename}    ${entity_id}
    Check Response Status Code    201    ${response.status_code}

    ${attribute_payload}=    Load Entity    ${entity_attribute_filename}    ${entity_id}
    Set Stub Reply    PUT    /broker1/ngsi-ld/v1/entities/${entity_id}/attrs/${attribute_name}    204

    ${response}=    Replace Attribute Selecting Content Type
    ...    entity_id=${entity_id}
    ...    attr_id=${attribute_name}
    ...    attribute_fragment=${attribute_payload}
    ...    content_type=${CONTENT_TYPE_JSON}
    ...    context=${ngsild_test_suite_context}
    Check Response Status Code    204    ${response.status_code}

    ${stub_count}=    Get Stub Count    PUT    /broker1/ngsi-ld/v1/entities/${entity_id}/attrs/${attribute_name}
    Should Be Equal As Integers    ${stub_count}    1

    ${response}=    Retrieve Entity    ${entity_id}    context=${ngsild_test_suite_context}    local=true
    Should Not Contain    ${response.json()}    ${attribute_name}

*** Keywords ***
Create Entity And Registration On The Context Broker And Start Context Source Mock Server
    ${entity_id}=    Generate Random Vehicle Entity Id
    Set Suite Variable    ${entity_id}

    ${registration_id}=    Generate Random CSR Id
    Set Suite Variable    ${registration_id}
    ${registration_payload}=    Prepare Context Source Registration From File
    ...    ${registration_id}
    ...    ${registration_payload_file_path}
    ...    entity_id=${entity_id}
    ...    mode=exclusive
    ...    endpoint=/broker1
    ${response}=    Create Context Source Registration With Return    ${registration_payload}
    Check Response Status Code    201    ${response.status_code}

    Start Context Source Mock Server

Delete Created Entity And Registration And Stop Context Source Mock Server
    Delete Context Source Registration    ${registration_id}
    Delete Entity    ${entity_id}
