*** Settings ***
Documentation       Verify that, when one has an inclusive registration on a Context Broker and an entity only on a Context Source, if one queries the Context Broker Via Post the request gets forwarded to the Context Source correctly using the appropriate operation

Resource            ${EXECDIR}/resources/ApiUtils/Common.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistration.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceDiscovery.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource
Resource            ${EXECDIR}/resources/MockServerUtils.resource

Test Teardown       Delete Registration And Stop Context Source Mock Server
Test Template       Setup Registration, Context Source Mock Server And Query The Context Broker With Type Via POST


*** Variables ***
${entity_payload_filename}              vehicle-simple-attributes.json
${registration_payload_file_path}       csourceRegistrations/context-source-registration-vehicle-complete.jsonld


*** Test Cases ***
D011_04_01_inc Query The Context Broker By Id Via POST Using The queryBatch Operation
    [Documentation]    Check that if one queries the Context Broker for type via POST, and the registration only allows the queryBatch operation, the request is forwarded as expected
    [Tags]    since_v1.6.1    dist-ops    4_3_3    cf_06    additive-inclusive    4_3_6_2    5_7_2    6_23_3
    [Template]    Setup Registration, Context Source Mock Server And Query The Context Broker With Type Via POST
    queryBatch    POST    /ngsi-ld/v1/entityOperations/query
D011_04_02_inc Query The Context Broker By Id Via POST Using The queryEntity Operation
    [Documentation]    Check that if one queries the Context Broker for type via POST, and the registration only allows the queryEntity operation, the request is forwarded as expected
    [Tags]    since_v1.6.1    dist-ops    4_3_3    cf_06    additive-inclusive    4_3_6_2    5_7_2    6_23_3
    [Template]    Setup Registration, Context Source Mock Server And Query The Context Broker With Type Via POST
    queryEntity    GET    /ngsi-ld/v1/entities?type=Vehicle


*** Keywords ***
Setup Registration, Context Source Mock Server And Query The Context Broker With Type Via POST
    [Arguments]    ${operation}    ${method}    ${url}
    ${entity_id}=    Generate Random Vehicle Entity Id

    ${registration_id}=    Generate Random CSR Id
    Set Suite Variable    ${registration_id}
    ${operations}=    Create List    ${operation}
    ${registration_payload}=    Prepare Context Source Registration From File
    ...    ${registration_id}
    ...    ${registration_payload_file_path}
    ...    operations=${operations}
    ${response1}=    Create Context Source Registration With Return    ${registration_payload}
    Check Response Status Code    201    ${response1.status_code}
    Start Context Source Mock Server

    ${entity_body}=    Load Entity    ${entity_payload_filename}    ${entity_id}
    Set Stub Reply    ${method}    ${url}    200    ${entity_body}
    &{entities}=    Create Dictionary
    Set To Dictionary    ${entities}    id=${entity_id}
    @{entities}=    Create List    ${entities}
    ${response}=    Query Entities Via POST    entities=${entities}    context=${ngsild_test_suite_context}

    Check Response Status Code    200    ${response.status_code}
    @{entities_id}=    Create List    ${entity_id}
    Check Response Body Containing Entities URIS set to    ${entities_id}    ${response.json()}

Delete Registration And Stop Context Source Mock Server
    Delete Context Source Registration    ${registration_id}
    Stop Context Source Mock Server
