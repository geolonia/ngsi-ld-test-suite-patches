*** Settings ***
Documentation       Common keywords used in setup steps for interoperability

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceDiscovery.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistration.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

*** Keywords ***
Compose IOP Configuration
    [Arguments]    ${sets}

    ${len}=    Get Length    ${sets}
    FOR    ${i}    IN RANGE    ${len}
        ${entity_id}=    Get From List    ${sets}[${i}]    0
        ${registration_filename}=    Get From List    ${sets}[${i}]    1
        ${mode}=    Get From List    ${sets}[${i}]    2
        ${broker_url}=    Get From List    ${sets}[${i}]    3
        ${registration_broker_url}=    Get From List    ${sets}[${i}]    4
        ${registration_id${i+1}}=    Generate Random CSR Id
        Set Suite Variable    ${registration_id${i+1}}
        ${registration_broker_url${i+1}}=    Set Variable    ${registration_broker_url}
        Set Suite Variable    ${registration_broker_url${i+1}}
        ${registration_payload}=    Prepare Context Source Registration From File
        ...    ${registration_id${i+1}}
        ...    ${registration_filename}
        ...    entity_id=${entity_id}
        ...    mode=${mode}
        ...    broker_url=${broker_url}
        ${response}=    Create Context Source Registration With Return
        ...    ${registration_payload}
        ...    content_type=${CONTENT_TYPE_LD_JSON}
        ...    broker_url=${registration_broker_url}
        Check Response Status Code    201    ${response.status_code}
    END

Delete Registrations And Entities
    [Arguments]    ${brokers_url}
    ...            ${entities}

    ${len_brokers}=    Get Length    ${brokers_url}
    ${len_entities}=    Get Length    ${entities}
    FOR    ${i}    IN RANGE    ${len_brokers}-1
        Delete Context Source Registration With Return    ${registration_id${i+1}}    broker_url=${registration_broker_url${i+1}}
    END
    FOR    ${i}    IN RANGE    ${len_entities}-1
        Delete Entity    ${entities}[${i}]
    END