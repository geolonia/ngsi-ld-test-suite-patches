*** Settings ***
Variables    ./variables.py

Library    REST    ${url}
Library    RequestsLibrary
Library    OperatingSystem
Library    Collections

*** Variables ***
${BATCH_CREATE_ENDPOINT_PATH}   entityOperations/create
${BATCH_UPSERT_ENDPOINT_PATH}   entityOperations/upsert
${BATCH_UPDATE_ENDPOINT_PATH}   entityOperations/update
${BATCH_DELETE_ENDPOINT_PATH}   entityOperations/delete
${ENTITIES_ENDPOINT_PATH}       entities
${response}
&{BATCH_OPERATION_ENDPOINT_MAPPING}    create=${BATCH_CREATE_ENDPOINT_PATH}    upsert=${BATCH_UPSERT_ENDPOINT_PATH}    update=${BATCH_UPDATE_ENDPOINT_PATH}    delete=${BATCH_DELETE_ENDPOINT_PATH}

*** Keywords ***
Api POST request
    [Arguments]    ${api path}    ${header}    ${body}    
    ${response}    POST    ${api path}/    headers=${header}    body=${body}
    Output    request
    Output    response
    Output Schema
    Set Test Variable    ${response}

Api GET request
    [Arguments]    ${api path}   ${header}    
    ${response}    GET    ${api path}    headers=${header}
    Output    request
    Output    response
    Output Schema
    Set Test Variable    ${response}

Api DEL request
    [Arguments]    ${header}    ${api path}
    ${response}    DEL    ${api path}    headers=${header}
    Output    request
    Output    response
    Output Schema
    Set Test Variable    ${response}

Delete Entity by Id
    [Arguments]  ${id}
    ${response}=  DELETE  ${ENTITIES_ENDPOINT_PATH}/${id}
    Output  request
    Output  response

Create Entity
    [Arguments]  ${filename}    ${entity_id}
    ${entity_payload}=    Load Json From File    ${EXECDIR}/data/entities/${filename}
    ${entity}=    Update Value To Json    ${entity_payload}     $..id   ${entity_id}

    &{headers}=  Create Dictionary  Content-Type=application/ld+json
    ${response}=  POST  ${ENTITIES_ENDPOINT_PATH}  body=${entity}  headers=${headers}
    Output  request
    Output  response

Batch Create Entities
    [Arguments]  @{entities_to_be_created}
    &{headers}=  Create Dictionary  Content-Type=application/ld+json
    ${response}=  POST  ${BATCH_CREATE_ENDPOINT_PATH}  body=@{entities_to_be_created}  headers=${headers}
    Output  request
    Output  response
    Set Test Variable  ${response}

Batch Upsert Entities
    [Arguments]  @{entities_to_be_upserted}     ${update_option}=replace
    &{headers}=  Create Dictionary  Content-Type=application/ld+json
    ${response}=  POST  ${BATCH_UPSERT_ENDPOINT_PATH}?options=${update_option}  body=@{entities_to_be_upserted}  headers=${headers}
    Output  request
    Output  response
    Set Test Variable  ${response}

Batch Update Entities
    [Arguments]  @{entities_to_be_updated}           ${overwrite_option}=overwrite
    &{headers}=  Create Dictionary  Content-Type=application/ld+json
    ${response}=  POST  ${BATCH_UPDATE_ENDPOINT_PATH}?options=${overwrite_option}  body=@{entities_to_be_updated}  headers=${headers}
    Output  request
    Output  response
    Set Test Variable  ${response}

Batch Delete Entities
    [Arguments]  @{entities_ids_to_be_deleted}
    &{headers}=  Create Dictionary  Content-Type=application/ld+json
    ${response}=  POST  ${BATCH_DELETE_ENDPOINT_PATH}  body=@{entities_ids_to_be_deleted}  headers=${headers}
    Output  request
    Output  response
    Set Test Variable  ${response}

Batch Request Entities From File
    [Arguments]  ${batchOperation}      ${filename}
    ${file_content}=    Get File    ${EXECDIR}/data/entities/${filename}
    ${endpoint_url}=    Get From Dictionary     ${BATCH_OPERATION_ENDPOINT_MAPPING}     ${batchOperation}
    Create Session    BatchRequest      ${url}
    &{headers}=  Create Dictionary  Content-Type=application/ld+json
    ${response}=  POST Request      BatchRequest   ${endpoint_url}  data=${file_content}    headers=${headers}
    Set Test Variable  ${response}
