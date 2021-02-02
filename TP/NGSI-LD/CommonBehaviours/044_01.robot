*** Settings ***
Documentation   Verify that PATCH HTTP requests can be done with "application/merge-patch+json" as Content-Type 
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

*** Test Cases ***                                                                ID                              DELETE_ID                         ENDPOINT                                                              FILENAME_PATH                                                                           
044_01_01_endpoint /entities/{entityId}/attrs/                                    ${entity_id}                    ${entity_id}                      ${ENTITIES_ENDPOINT_PATH}{entityId}/attrs/                                             entities/building-minimal-without-context-sample.jsonld 
044_01_02_endpoint /entities/{entityId}/attrs/{attrId}                            ${csourceRegistration_id}       ${csourceRegistration_id}         /entities/{entityId}/attrs/{attrId}                          csourceRegistrations/context-source-registration-without-context-sample.jsonld                         
044_01_03_endpoint /subscriptions/{subscriptionId}                                ${subscription_id}              ${subscription_id}                /subscriptions/{subscriptionId}                                        csourceSubscriptions/subscription-without-context-sample.jsonld
044_01_04_endpoint /csourceRegistrations/{registrationId}                         ${csourceSubscription_id}       ${csourceSubscription_id}        /csourceRegistrations/{registrationId}             csourceSubscriptions/subscription-without-context-sample.jsonld
044_01_05_endpoint /csourceSubscriptions/{subscriptionId}                         ${temporal_entity_id}           ${temporal_entity_id}            /csourceSubscriptions/{subscriptionId}                                    temporalEntities/bus-temporal-representation-without-context-sample.jsonld
044_01_06_endpoint /temporal/entities/{entityId}/attrs/{attrId}/{instanceId}                                                                        /temporal/entities/{entityId}/attrs/{attrId}/{instanceId}

*** Keywords ***                               
PATCH HTTP requests via "application/merge-patch+json"
    [Arguments]  ${id}     ${delete_id}     ${endpoint}     ${filename_path}
    [Documentation]  Verify that PATCH HTTP requests can be done with "application/merge-patch+json" as Content-Type 
    [Tags]  mandatory

    ${response}=    Merge Request By Selecting Endpoint    ${id}    ${endpoint}    ${filename_path}
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