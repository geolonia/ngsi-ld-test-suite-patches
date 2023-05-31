*** Settings ***
Library         String
Library         DateTime
Library         JSONLibrary
Variables       ${EXECDIR}/resources/variables.py


*** Variables ***
${date_format}=                 %Y-%m-%dT%H:%M:%SZ
${notification_server_url}=     http://${notification_server_host}:${notification_server_port}/notify
${context_source_url}=          http://${context_source_host}:${context_source_port}


*** Keywords ***
Load Entity
    [Arguments]    ${entity_file_name}    ${entity_id}

    ${entity_payload}=    Load JSON From File    ${EXECDIR}/data/entities/${entity_file_name}
    ${entity}=    Update Value To JSON    ${entity_payload}    $..id    ${entity_id}
    RETURN    ${entity}

Load Test Sample
    [Arguments]    ${test_sample_file_path}    ${test_sample_id}=${EMPTY}

    ${test_sample_payload}=    Load JSON From File    ${EXECDIR}/data/${test_sample_file_path}
    ${test_sample}=    Update Value To JSON    ${test_sample_payload}    $..id    ${test_sample_id}

    IF    '${test_sample_id}'==''
        Delete Object From JSON    ${test_sample}    $..id
    END
    RETURN    ${test_sample}

Load Subscription Sample With Reachable Endpoint
    [Arguments]
    ...    ${subscription_file_path}
    ...    ${subscription_id}=${EMPTY}
    ...    ${notification_endpoint_uri}=${notification_server_url}

    ${subscription_payload}=    Load Test Sample    ${subscription_file_path}    ${subscription_id}
    ${subscription}=    Update Value To JSON
    ...    ${subscription_payload}
    ...    $..notification['endpoint']['uri']
    ...    ${notification_endpoint_uri}
    RETURN    ${subscription}

Set Entity Id In Subscription
    [Arguments]    ${subscription_payload}    ${entity_id}
    ${dict}=    Create Dictionary    id=${entity_id}
    ${subscription}=    Add Object To JSON    ${subscription_payload}    $..entities[0]    ${dict}
    RETURN    ${subscription}

Load Context Source Registration Sample With Reachable Context Source
    [Arguments]
    ...    ${context_source_registration_file_path}
    ...    ${context_source_registration_id}=${EMPTY}
    ...    ${context_source_endpoint_uri}=${context_source_url}

    ${context_source_registration_payload}=    Load Test Sample
    ...    ${context_source_registration_file_path}
    ...    ${context_source_registration_id}
    ${context_source_registration}=    Update Value To JSON
    ...    ${context_source_registration_payload}
    ...    $..endpoint
    ...    ${context_source_endpoint_uri}
    RETURN    ${context_source_registration}

Remove Entity Type
    [Arguments]    ${entity}

    ${invalid_entity}=    Delete Object From JSON    ${entity}    $..type
    RETURN    ${invalid_entity}

Generate Random Entity Id
    [Arguments]    ${id_prefix}

    ${random_id}=    Generate Random String    16    [NUMBERS]
    ${entity_id}=    Catenate    ${id_prefix}${random_id}
    RETURN    ${entity_id}

Create Batch Operation Result
    [Arguments]    ${success}    ${errors}

    &{batch_operation_result}=    Create Dictionary    success=${success}    errors=${errors}
    RETURN    &{batch_operation_result}

Upsert Element In Entity
    [Arguments]    ${initial_entity}    ${fragment}    ${jsonPath}=$

    ${updated_entity}=    Add Object To JSON    ${initial_entity}    ${jsonPath}    ${fragment}
    RETURN    ${updated_entity}
