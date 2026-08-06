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
    ...    ${ld_context}=${ngsild_test_suite_context}

    ${len}=    Get Length    ${sets}
    Set Test Variable    ${registration_count}    0
    FOR    ${i}    IN RANGE    ${len}
        ${entity_id}=    Get From List    ${sets}[${i}]    0
        ${registration_filename}=    Get From List    ${sets}[${i}]    1
        ${mode}=    Get From List    ${sets}[${i}]    2
        ${endpoint}=    Get From List    ${sets}[${i}]    3
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
        ...    endpoint=${endpoint}
        ...    context=${ld_context}
        ${response}=    Create Context Source Registration With Return
        ...    ${registration_payload}
        ...    content_type=${CONTENT_TYPE_LD_JSON}
        ...    broker_url=${registration_broker_url}
        Check Response Status Code    201    ${response.status_code}
        ${created_count}=    Evaluate    $i + 1
        Set Test Variable    ${registration_count}    ${created_count}
    END

Delete Registrations And Entities
    [Arguments]    ${brokers_url}
    ...    ${entities}

    ${created_count}=    Get Variable Value    \${registration_count}    0
    ${registration_end}=    Evaluate    int($created_count) + 1
    FOR    ${i}    IN RANGE    1    ${registration_end}
        Delete Context Source Registration With Return
        ...    ${registration_id${i}}
        ...    broker_url=${registration_broker_url${i}}
    END
    ${temporal_cleanup_setting}=    Set Variable    ${delete_temporal_on_core_delete}
    Set Test Variable    ${delete_temporal_on_core_delete}    ${False}
    FOR    ${broker_url}    IN    @{brokers_url}
        FOR    ${entity_id}    IN    @{entities}
            Delete Entity    ${entity_id}    local=true    broker_url=${broker_url}
        END
    END
    Set Test Variable    ${delete_temporal_on_core_delete}    ${temporal_cleanup_setting}
