*** Settings ***

Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistration.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource
Resource            ${EXECDIR}/resources/MockServerUtils.resource

Suite Setup         Create Entity And Registration On The Context Broker And Start Context Source Mock Server
Suite Teardown      Delete Created Entity And Registration And Stop Context Source Mock Server


*** Variables ***
${entity_id_prefix}                     urn:ngsi-ld:Vehicle:
${entity_payload_filename}              vehicle-simple-attributes.jsonld
${registration_id_prefix}               urn:ngsi-ld:Registration:
${registration_payload_file_path}       csourceRegistrations/context-source-registration-vehicle-redirection-ops.jsonld

*** Test Cases ***
D002_03_inc Delete Entity With Local Flag
    [Documentation]    Verify that, when one has an inclusive registration on a Context Broker, one is able to delete an entity with local flag and the operation should not be forwarded to the Context Source
    [Tags]    since_v1.6.1    dist-ops    4_3_3    cf_06    additive-inclusive    4_3_6_2    5_6_6    6_3_18
    ${response}=    Delete Entity by Id    ${entity_id}    local=true
    Check Response Status Code    204    ${response.status_code}

    Wait For No Request

*** Keywords ***
Create Entity And Registration On The Context Broker And Start Context Source Mock Server
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

Delete Created Entity And Registration And Stop Context Source Mock Server
    Delete Context Source Registration    ${registration_id}
    Delete Entity By Id    ${entity_id}
    Stop Context Source Mock Server