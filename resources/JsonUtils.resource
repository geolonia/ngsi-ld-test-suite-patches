*** Settings ***
Library     String
Library     DateTime
Library     JSONLibrary

*** Variable ***
${date_format}=  %Y-%m-%dT%H:%M:%SZ
${notification_server_url}=     http://${notification_server_host}:${notification_server_port}/notify
${context_source_url}=     http://${context_source_host}:${context_source_port}

*** Keywords ***
Load Entity
    [Arguments]    ${entity_file_name}     ${entity_id}

    ${entity_payload}=    Load Json From File    ${EXECDIR}/data/entities/${entity_file_name}
    ${entity}=    Update Value To Json    ${entity_payload}     $..id   ${entity_id}

    [return]    ${entity}

Load Test Sample
    [Arguments]    ${test_sample_file_path}     ${test_sample_id}=${EMPTY}

    ${test_sample_payload}=    Load Json From File    ${EXECDIR}/data/${test_sample_file_path}
    ${test_sample}=    Update Value To Json    ${test_sample_payload}     $..id   ${test_sample_id}

    Run Keyword If     '${test_sample_id}'==''       Delete Object From Json    ${test_sample}     $..id

    [return]    ${test_sample}

Load Subscription Sample With Reachable Endpoint
    [Arguments]    ${subscription_file_path}     ${subscription_id}=${EMPTY}      ${notification_endpoint_uri}=${notification_server_url}

    ${subscription_payload}=  Load Test Sample    ${subscription_file_path}    ${subscription_id}
    ${subscription}=    Update Value To Json    ${subscription_payload}     $..notification['endpoint']['uri']   ${notification_endpoint_uri}

    [return]    ${subscription}

Load Context Source Registration Sample With Reachable Context Source
    [Arguments]    ${context_source_registration_file_path}     ${context_source_registration_id}=${EMPTY}      ${context_source_endpoint_uri}=${context_source_url}

    ${context_source_registration_payload}=  Load Test Sample    ${context_source_registration_file_path}    ${context_source_registration_id}
    ${context_source_registration}=    Update Value To Json    ${context_source_registration_payload}     $..endpoint   ${context_source_endpoint_uri}

    [return]    ${context_source_registration}

Remove Entity Type
    [Arguments]    ${entity}

    ${invalid_entity}=    Delete Object From Json    ${entity}     $..type

    [return]    ${invalid_entity}

Generate Random Entity Id
    [Arguments]    ${id_prefix}

    ${random_id}=     Generate Random String    16    [NUMBERS]
    ${entity_id}=    Catenate    ${id_prefix}${random_id}

    [return]    ${entity_id}

Create Batch Operation Result
    [Arguments]    ${success}       ${errors}

    &{batch_operation_result}=      Create Dictionary	success=${success}      errors=${errors}

    [return]    &{batch_operation_result}
