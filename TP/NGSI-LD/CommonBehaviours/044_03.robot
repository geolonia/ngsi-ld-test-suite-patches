*** Settings ***
Documentation   Verify throwing 503 – LDContextNotAvaliable error if remote JSON-LD @context cannot be retrieved 
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Suite Setup    Generate Random Ids
Test Template  Throw 503 LDContextNotAvaliable error 

*** Variable ***
${expected_status_code}=  503
${building_id_prefix}=  urn:ngsi-ld:Building:
${registration_id_prefix}=  urn:ngsi-ld:Registration:
${subscription_id_prefix}=  urn:ngsi-ld:Subscription:

*** Test Cases ***                          ID                              DELETE_ID                         ENDPOINT                                                              FILENAME_PATH                                                                           
043_01_endpoint /entities/                  ${entity_id}                    ${entity_id}                      ${ENTITIES_ENDPOINT_PATH}                                             entities/building-minimal-without-context-sample.jsonld 
043_02_endpoint /csourceRegistrations/      ${csourceRegistration_id}       ${csourceRegistration_id}         ${CONTEXT_SOURCE_REGISTRATION_ENDPOINT_PATH}                          csourceRegistrations/context-source-registration-without-context-sample.jsonld                         
043_03_endpoint /subscriptions/             ${subscription_id}              ${subscription_id}                ${SUBSCRIPTION_ENDPOINT_PATH}                                         csourceSubscriptions/subscription-without-context-sample.jsonld
043_04_endpoint /csourceSubscriptions/      ${csourceSubscription_id}       /${csourceSubscription_id}        ${CONTEXT_SOURCE_REGISTRATION_SUBSCRIPTION_ENDPOINT_PATH}             csourceSubscriptions/subscription-without-context-sample.jsonld
043_05_endpoint /temporal/entities/         ${temporal_entity_id}           /${temporal_entity_id}            ${TEMPORAL_ENTITIES_ENDPOINT_PATH}                                    temporalEntities/bus-temporal-representation-without-context-sample.jsonld

*** Keywords ***                               
Throw 503 LDContextNotAvaliable error 
    [Arguments]  ${id}     ${delete_id}     ${endpoint}     ${filename_path}
    [Documentation]  Verify throwing 503 – LDContextNotAvaliable error if remote JSON-LD @context cannot be retrieved 
    [Tags]  mandatory

    ${response}=    Create Request By Selecting Endpoint    ${id}    ${endpoint}    ${filename_path}
    Check Response Status Code  ${expected_status_code}    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_LD_CONTEXT_NOT_AVAILABLE}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}
    
    [Teardown]  Delete Request By Selecting Endpoint/Id  ${delete_id}    ${endpoint}

Generate Random Ids
    ${entity_id}=       Generate Random Entity Id    ${building_id_prefix}
    ${temporal_entity_id}=       Generate Random Entity Id    ${building_id_prefix}
    ${csourceRegistration_id}=       Generate Random Entity Id    ${registration_id_prefix}
    ${csourceSubscription_id}=       Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_id}=       Generate Random Entity Id    ${subscription_id_prefix}
    Set Suite Variable  ${entity_id}
    Set Suite Variable  ${temporal_entity_id}
    Set Suite Variable  ${csourceRegistration_id}
    Set Suite Variable  ${csourceSubscription_id}
    Set Suite Variable  ${subscription_id}