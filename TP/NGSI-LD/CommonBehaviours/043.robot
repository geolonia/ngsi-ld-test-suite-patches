*** Settings ***
Documentation   Verify throwing 503 – LDContextNotAvaliable error if remote JSON-LD @context cannot be retrieved 
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Throw 503 LDContextNotAvaliable error 

*** Variable ***
${expected_status_code}=  503
${building_id_prefix}=  urn:ngsi-ld:Building:
${registration_id_prefix}=  urn:ngsi-ld:Registration:
${subscription_id_prefix}=  urn:ngsi-ld:Subscription:

*** Test Cases ***                          PREFIX                              DELETE_PREFIX             ENDPOINT                                                              FILENAME_PATH                                                                           
043_01_endpoint /entities/                  ${building_id_prefix}               ${EMPTY}                  ${ENTITIES_ENDPOINT_PATH}                                             entities/building-minimal-without-context-sample.jsonld 
043_02_endpoint /csourceRegistrations/      ${registration_id_prefix}           ${EMPTY}                  ${CONTEXT_SOURCE_REGISTRATION_ENDPOINT_PATH}                          csourceRegistrations/context-source-registration-without-context-sample.jsonld                         
043_03_endpoint /subscriptions/             ${subscription_id_prefix}           ${EMPTY}                  ${SUBSCRIPTION_ENDPOINT_PATH}                                         csourceSubscriptions/subscription-without-context-sample.jsonld
043_04_endpoint /csourceSubscriptions/      ${subscription_id_prefix}           /                         ${CONTEXT_SOURCE_REGISTRATION_SUBSCRIPTION_ENDPOINT_PATH}             csourceSubscriptions/subscription-without-context-sample.jsonld
043_05_endpoint /temporal/entities/         ${building_id_prefix}               /                         ${TEMPORAL_ENTITIES_ENDPOINT_PATH}                                    temporalEntities/bus-temporal-representation-without-context-sample.jsonld

*** Keywords ***                               
Throw 503 LDContextNotAvaliable error 
    [Arguments]  ${prefix}     ${delete_prefix}     ${endpoint}     ${filename_path}
    [Documentation]  Verify throwing 503 – LDContextNotAvaliable error if remote JSON-LD @context cannot be retrieved 
    [Tags]  mandatory

    ${create_id}=       Generate Random Entity Id    ${prefix}    
    ${delete_id}=       Set Variable    ${delete_prefix}${create_id}  

    ${response}=    Create Request By Selecting Endpoint    ${create_id}    ${endpoint}    ${filename_path}
    Check Response Status Code  ${expected_status_code}    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_LD_CONTEXT_NOT_AVAILABLE}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}
    
    [Teardown]  Delete Request By Selecting Endpoint/Id  ${delete_id}    ${endpoint}