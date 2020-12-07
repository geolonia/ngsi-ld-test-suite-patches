*** Settings ***
Variables    ./variables.py

Library    REST    ${url}

*** Variables ***
${response}

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
    ${response}=  DELETE  ${endpoint}/${id}
    Output  request
    Output  response

Create Entity
    [Arguments]  ${filename}    ${entity_id}
    ${entity_payload}=    Load Json From File    ${EXECDIR}/data/entities/${filename}
    ${entity}=    Update Value To Json    ${entity_payload}     $..id   ${entity_id}

    &{headers}=  Create Dictionary  Content-Type=application/ld+json
    ${response}=  POST  ${endpoint}  body=${entity}  headers=${headers}
    Output  request
    Output  response

Batch Create Entities
    [Arguments]  @{entities_to_be_created}
    &{headers}=  Create Dictionary  Content-Type=application/ld+json
    ${response}=  POST  ${batch_endpoint}  body=@{entities_to_be_created}  headers=${headers}
    Output  request
    Output  response
    Set Test Variable  ${response}

Batch Upsert Entities
    [Arguments]  @{entities_to_be_upserted}     ${update_option}=replace
    &{headers}=  Create Dictionary  Content-Type=application/ld+json
    ${response}=  POST  ${batch_endpoint}?options=${update_option}  body=@{entities_to_be_upserted}  headers=${headers}
    Output  request
    Output  response
    Set Test Variable  ${response}

Batch Update Entities
    [Arguments]  @{entities_to_be_updated}           ${overwrite_option}=overwrite
    &{headers}=  Create Dictionary  Content-Type=application/ld+json
    ${response}=  POST  ${batch_endpoint}?options=${overwrite_option}  body=@{entities_to_be_updated}  headers=${headers}
    Output  request
    Output  response
    Set Test Variable  ${response}

Batch Delete Entities
    [Arguments]  @{entities_ids_to_be_deleted}
    &{headers}=  Create Dictionary  Content-Type=application/ld+json
    ${response}=  POST  ${batch_delete_endpoint}  body=@{entities_ids_to_be_deleted}  headers=${headers}
    Output  request
    Output  response
    Set Test Variable  ${response}

Batch Request Entities From File
    [Arguments]  ${filename}
    ${file_content}=    Get File    ${EXECDIR}/data/entities/${filename}
    Create Session    BatchRequest      ${url}
    &{headers}=  Create Dictionary  Content-Type=application/ld+json
    ${response}=  POST Request      BatchRequest   ${batch_endpoint}  data=${file_content}    headers=${headers}
    Set Test Variable  ${response}      ${response.json()}
