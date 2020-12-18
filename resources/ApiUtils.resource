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
&{BATCH_OPERATION_ENDPOINT_MAPPING}    create=${BATCH_CREATE_ENDPOINT_PATH}    upsert=${BATCH_UPSERT_ENDPOINT_PATH}    update=${BATCH_UPDATE_ENDPOINT_PATH}    delete=${BATCH_DELETE_ENDPOINT_PATH}
${ENTITIES_ENDPOINT_PATH}       entities
${TEMPORAL_ENTITIES_ENDPOINT_PATH}       temporal/entities
${TEMPORAL_ENTITY_OPERATIONS_ENDPOINT_PATH}       temporal/entityOperations

${CONTENT_TYPE_JSON}            application/json
${CONTENT_TYPE_LD_JSON}         application/ld+json

${ERROR_TYPE_BAD_REQUEST_DATA}      https://uri.etsi.org/ngsi-ld/errors/BadRequestData
${ERROR_TYPE_INVALID_REQUEST}      https://uri.etsi.org/ngsi-ld/errors/InvalidRequest
${ERROR_TYPE_RESOURCE_NOT_FOUND}      https://uri.etsi.org/ngsi-ld/errors/ResourceNotFound

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
    ${response}=  DELETE  ${ENTITIES_ENDPOINT_PATH}/${id}
    Output  request
    Output  response

Retrieve Entity by Id
    [Arguments]  ${id}      ${accept}=${CONTENT_TYPE_LD_JSON}     ${context}=${EMPTY}
    ${headers}=  Create Dictionary
    Set To Dictionary   ${headers}   Accept    ${accept}
    Run Keyword If     '${context}'!=''       Set To Dictionary   ${headers}   Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    ${response}=  GET  ${ENTITIES_ENDPOINT_PATH}/${id}  headers=${headers}
    Output  request
    Output  response
    Set Test Variable   ${response}

Create Entity
    [Arguments]  ${filename}    ${entity_id}
    ${entity_payload}=    Load Json From File    ${EXECDIR}/data/entities/${filename}
    ${entity}=    Update Value To Json    ${entity_payload}     $..id   ${entity_id}

    &{headers}=  Create Dictionary  Content-Type=application/ld+json
    ${response}=  POST  ${ENTITIES_ENDPOINT_PATH}  body=${entity}  headers=${headers}
    Output  request
    Output  response

Batch Create Entities
    [Arguments]  @{entities_to_be_created}      ${content_type}=${CONTENT_TYPE_LD_JSON}     ${context}=${EMPTY}
    ${headers}=  Create Dictionary
    Set To Dictionary   ${headers}   Content-Type    ${content_type}
    Run Keyword If     '${context}'!=''       Set To Dictionary   ${headers}   Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
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
    [Arguments]  @{entities_ids_to_be_deleted}  ${teardown}=False
    &{headers}=  Create Dictionary  Content-Type=application/ld+json
    ${response}=  POST  ${BATCH_DELETE_ENDPOINT_PATH}  body=@{entities_ids_to_be_deleted}  headers=${headers}
    Output  request
    Output  response
    Run Keyword If     not ${teardown}       Set Test Variable  ${response}

Batch Request Entities From File
    [Arguments]  ${batchOperation}      ${filename}
    ${file_content}=    Get File    ${EXECDIR}/data/entities/${filename}
    ${endpoint_url}=    Get From Dictionary     ${BATCH_OPERATION_ENDPOINT_MAPPING}     ${batchOperation}
    Create Session    BatchRequest      ${url}
    &{headers}=  Create Dictionary  Content-Type=application/ld+json
    ${response}=  POST Request      BatchRequest   ${endpoint_url}  data=${file_content}    headers=${headers}
    Set Test Variable  ${response}

Create Temporal Representation Of Entity
    [Arguments]  ${filename}    ${temporal_entity_representation_id}
    ${temporal_entity_representation_payload}=    Load Json From File    ${EXECDIR}/data/temporalEntities/${filename}
    ${temporal_entity_representation}=    Update Value To Json    ${temporal_entity_representation_payload}     $..id   ${temporal_entity_representation_id}

    &{headers}=  Create Dictionary  Content-Type=application/ld+json
    ${response}=  POST  ${TEMPORAL_ENTITIES_ENDPOINT_PATH}  body=${temporal_entity_representation}  headers=${headers}
    Output  request
    Output  response

Retrieve Temporal Representation Of Entity
    [Arguments]  ${temporal_entity_representation_id}   ${attrs}=${EMPTY}      ${options}=${EMPTY}      ${context}=${EMPTY}     ${timerel}=${EMPTY}      ${timeAt}=${EMPTY}    ${endTimeAt}=${EMPTY}    ${lastN}=${EMPTY}
    ${attrs_length} =  Get Length  ${attrs}
    ${options_length} =  Get Length  ${options}
    &{headers}=  Create Dictionary
    &{params}=  Create Dictionary

    Run Keyword If     '${context}'!=''       Set To Dictionary   ${headers}    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    Run Keyword If     ${attrs_length}>0       Set To Dictionary   ${params}       attrs=${attrs}
    Run Keyword If     ${options_length}>0       Set To Dictionary   ${params}       options=${options}
    Run Keyword If     '${timerel}'!=''       Set To Dictionary   ${params}    timerel=${timerel}
    Run Keyword If     '${timeAt}'!=''       Set To Dictionary   ${params}    timeAt=${timeAt}
    Run Keyword If     '${endTimeAt}'!=''       Set To Dictionary   ${params}    endTimeAt=${endTimeAt}
    Run Keyword If     '${lastN}'!=''       Set To Dictionary   ${params}    lastN=${lastN}

    ${response}=  GET  ${TEMPORAL_ENTITIES_ENDPOINT_PATH}/${temporal_entity_representation_id}      headers=${headers}      query=${params}
    Output  request
    Output  response
    Set Test Variable  ${response}

Query Temporal Representation Of Entities
    [Arguments]  ${context}=${EMPTY}     ${entity_types}=${EMPTY}   ${entity_ids}=${EMPTY}    ${entity_id_pattern}=${EMPTY}    ${ngsild_query}=${EMPTY}  ${georel}=${EMPTY}   ${geometry}=${EMPTY}    ${coordinates}=${EMPTY}    ${geoproperty}=${EMPTY}    ${timerel}=${EMPTY}      ${timeAt}=${EMPTY}     ${attrs}=${EMPTY}   ${limit}=${EMPTY}   ${lastN}=${EMPTY}
    ${entity_types_length} =  Get Length  ${entity_types}
    ${entity_ids_length} =  Get Length  ${entity_ids}
    ${attrs_length} =  Get Length  ${attrs}
    &{headers}=  Create Dictionary
    &{params}=  Create Dictionary
    Run Keyword If     '${context}'!=''       Set To Dictionary   ${headers}    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    Run Keyword If     ${entity_types_length}>0       Set To Dictionary   ${params}    type=${entity_types}
    Run Keyword If     ${entity_ids_length}>0       Set To Dictionary   ${params}    id=${entity_ids}
    Run Keyword If     '${timerel}'!=''       Set To Dictionary   ${params}    timerel=${timerel}
    Run Keyword If     '${timeAt}'!=''       Set To Dictionary   ${params}    timeAt=${timeAt}
    Run Keyword If     ${attrs_length}>0       Set To Dictionary   ${params}       attrs=${attrs}
    Run Keyword If     '${lastN}'!=''       Set To Dictionary   ${params}    lastN=${lastN}
    Run Keyword If     '${entity_id_pattern}'!=''       Set To Dictionary   ${params}    idPattern=${entity_id_pattern}
    Run Keyword If     '${ngsild_query}'!=''       Set To Dictionary   ${params}    q=${ngsild_query}
    Run Keyword If     '${georel}'!=''       Set To Dictionary   ${params}    georel=${georel}
    Run Keyword If     '${geometry}'!=''       Set To Dictionary   ${params}    geometry=${geometry}
    Run Keyword If     '${coordinates}'!=''       Set To Dictionary   ${params}    coordinates=${coordinates}
    Run Keyword If     '${geoproperty}'!=''       Set To Dictionary   ${params}    geoproperty=${geoproperty}
    Run Keyword If     '${limit}'!=''       Set To Dictionary   ${params}    limit=${limit}

    ${response}=  GET  ${TEMPORAL_ENTITIES_ENDPOINT_PATH}      headers=${headers}      query=${params}
    Output  request
    Output  response
    Set Test Variable  ${response}

Query Temporal Representation Of Entities Via Post
    [Arguments]  ${query_file_name}
    ${headers}=  Create Dictionary
    Set To Dictionary   ${headers}   Content-Type    ${CONTENT_TYPE_LD_JSON}
    ${query_payload}=    Load Json From File    ${EXECDIR}/data/temporalEntities/${query_file_name}
    ${response}=  POST  ${TEMPORAL_ENTITY_OPERATIONS_ENDPOINT_PATH}/query  body=${query_payload}  headers=${headers}
    Output  request
    Output  response
    Set Test Variable  ${response}

Delete Temporal Representation Of Entity
    [Arguments]  ${temporal_entity_representation_id}

    ${response}=  DELETE  ${TEMPORAL_ENTITIES_ENDPOINT_PATH}/${temporal_entity_representation_id}
    Output  request
    Output  response
