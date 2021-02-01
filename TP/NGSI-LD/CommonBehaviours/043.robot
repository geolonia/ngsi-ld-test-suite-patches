*** Settings ***
Documentation   Verify throwing 503 – LDContextNotAvaliable error if remote JSON-LD @context cannot be retrieved 
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Get Entity With Invalid/Missing Id

*** Variable ***
${expected_status_code}=  503

*** Test Cases ***                              ENDPOINT                                                              FILENAME_PATH
043_01_endpoint /entities/                      ${ENTITIES_ENDPOINT_PATH}                                             entities/building-minimal-without-context-sample.jsonld
#043_02_endpoint /csourceRegistrations/          ${CONTEXT_SOURCE_REGISTRATION_ENDPOINT_PATH}                          csourceRegistrations/context-source-registration-without-context-sample.jsonld                         
#043_03_endpoint /subscriptions/                 ${SUBSCRIPTION_ENDPOINT_PATH}                                         csourceSubscriptions/subscription-without-context-sample.jsonld
#043_04_endpoint /csourceSubscriptions/          ${CONTEXT_SOURCE_REGISTRATION_SUBSCRIPTION_ENDPOINT_PATH}             csourceSubscriptions/subscription-without-context-sample.jsonld
#043_05_endpoint /temporal/entities/             ${TEMPORAL_ENTITIES_ENDPOINT_PATH}                                    temporalEntities/bus-temporal-representation-without-context-sample.jsonld

*** Keywords ***                               
Get Entity With Invalid/Missing Id
    [Arguments]  ${endpoint}     ${filename_path}
    [Documentation]  Verify throwing 503 – LDContextNotAvaliable error if remote JSON-LD @context cannot be retrieved 
    [Tags]  mandatory

    ${response}=    Create Request By Selecting Endpoint    ${endpoint}    ${filename_path}
    Check Response Status Code  ${expected_status_code}    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_LD_CONTEXT_NOT_AVAILABLE}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}