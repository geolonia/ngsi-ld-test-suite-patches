*** Settings ***
Variables       ${EXECDIR}/resources/variables.py
Library         ${EXECDIR}/libraries/logUtils.py
Library         RequestsLibrary
Library         OperatingSystem
Library         Collections
Library         JSONLibrary


*** Variables ***
${BATCH_CREATE_ENDPOINT_PATH}           entityOperations/create
${BATCH_DELETE_ENDPOINT_PATH}           entityOperations/delete
&{BATCH_OPERATION_ENDPOINT_MAPPING}
...                                     create=${BATCH_CREATE_ENDPOINT_PATH}
${BATCH_UPDATE_ENDPOINT_PATH}           entityOperations/update
${BATCH_UPSERT_ENDPOINT_PATH}           entityOperations/upsert

${ENTITIES_ENDPOINT_PATH}               entities/

${CONTENT_TYPE_JSON}                    application/json
${CONTENT_TYPE_LD_JSON}                 application/ld+json

${ERROR_TYPE_ALREADY_EXISTS}            https://uri.etsi.org/ngsi-ld/errors/AlreadyExists
${ERROR_TYPE_BAD_REQUEST_DATA}          https://uri.etsi.org/ngsi-ld/errors/BadRequestData
${ERROR_TYPE_INVALID_REQUEST}           https://uri.etsi.org/ngsi-ld/errors/InvalidRequest
${ERROR_TYPE_RESOURCE_NOT_FOUND}        https://uri.etsi.org/ngsi-ld/errors/ResourceNotFound


*** Keywords ***
Append Entity Attributes
    [Arguments]    ${id}    ${fragment_filename}    ${content_type}
    &{headers}=    Create Dictionary    Content-Type=${content_type}
    ${file_content}=    Get File    ${EXECDIR}/data/entities/fragmentEntities/${fragment_filename}
    ${response}=    POST
    ...    url=${url}/${ENTITIES_ENDPOINT_PATH}${id}/attrs/
    ...    data=${file_content}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}    Append Entity Attributes
    RETURN    ${response}

Append Entity Attributes With Parameters
    [Arguments]    ${id}    ${fragment_filename}    ${content_type}    ${options}
    &{headers}=    Create Dictionary    Content-Type=${content_type}
    ${fragment_payload}=    Load JSON From File    ${EXECDIR}/data/entities/fragmentEntities/${fragment_filename}
    ${response}=    POST
    ...    url=${url}/${ENTITIES_ENDPOINT_PATH}${id}/attrs/?options=${options}
    ...    json=${fragment_payload}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}    Append Entity Attributes With Parameters
    RETURN    ${response}

Batch Create Entities
    [Arguments]
    ...    @{entities_to_be_created}
    ...    ${content_type}=${CONTENT_TYPE_LD_JSON}
    ...    ${context}=${EMPTY}
    ...    ${accept}=${EMPTY}
    ${headers}=    Create Dictionary
    Set To Dictionary    ${headers}    Content-Type    ${content_type}
    IF    '${accept}'!=''
        Set To Dictionary    ${headers}    Accept    ${accept}
    END
    IF    '${context}'!=''
        Set To Dictionary
        ...    ${headers}
        ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    END
    ${response}=    POST
    ...    url=${url}/${BATCH_CREATE_ENDPOINT_PATH}
    ...    json=@{entities_to_be_created}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}    Batch Create Entities
    RETURN    ${response}

Batch Delete Entities
    [Arguments]    @{entities_ids_to_be_deleted}    ${teardown}=False
    &{headers}=    Create Dictionary    Content-Type=application/ld+json
    ${response}=    POST
    ...    url=${url}/${BATCH_DELETE_ENDPOINT_PATH}
    ...    json=@{entities_ids_to_be_deleted}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}    Batch Delete Entities
    RETURN    ${response}

Batch Request Entities From File
    [Arguments]    ${batchOperation}    ${filename}
    ${file_content}=    Get File    ${EXECDIR}/data/entities/${filename}
    ${endpoint_url}=    Get From Dictionary    ${BATCH_OPERATION_ENDPOINT_MAPPING}    ${batchOperation}
    &{headers}=    Create Dictionary    Content-Type=application/ld+json
    ${response}=    POST
    ...    url=${url}/${endpoint_url}
    ...    data=${file_content}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}    Batch Request Entities From File
    RETURN    ${response}

Batch Update Entities
    [Arguments]    @{entities_to_be_updated}    ${overwrite_option}=overwrite
    &{headers}=    Create Dictionary    Content-Type=application/ld+json
    ${response}=    POST
    ...    url=${url}/${BATCH_UPDATE_ENDPOINT_PATH}?options=${overwrite_option}
    ...    json=@{entities_to_be_updated}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}    Batch Update Entities
    RETURN    ${response}

Batch Upsert Entities
    [Arguments]    @{entities_to_be_upserted}    ${update_option}=replace
    &{headers}=    Create Dictionary    Content-Type=application/ld+json
    ${response}=    POST
    ...    url=${url}/${BATCH_UPSERT_ENDPOINT_PATH}?options=${update_option}
    ...    json=@{entities_to_be_upserted}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}    Batch Upsert Entities
    RETURN    ${response}

Create Entity
    [Arguments]    ${filename}    ${entity_id}
    ${entity_payload}=    Load JSON From File    ${EXECDIR}/data/entities/${filename}
    ${entity}=    Update Value To JSON    ${entity_payload}    $..id    ${entity_id}
    &{headers}=    Create Dictionary    Content-Type=application/ld+json
    ${response}=    POST
    ...    url=${url}/${ENTITIES_ENDPOINT_PATH}
    ...    json=${entity}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}    Create Entity
    RETURN    ${response}

Create Entity Selecting Content Type
    [Arguments]    ${filename}    ${entity_id}    ${content_type}    ${context}=${EMPTY}    ${accept}=${EMPTY}
    ${entity_payload}=    Load JSON From File    ${EXECDIR}/data/entities/${filename}
    ${entity}=    Update Value To JSON    ${entity_payload}    $..id    ${entity_id}
    &{headers}=    Create Dictionary    Content-Type=${content_type}
    IF    '${accept}'!='${EMPTY}'
        Set To Dictionary    ${headers}    Accept=${accept}
    END
    IF    '${context}'!='${EMPTY}'
        Set To Dictionary
        ...    ${headers}
        ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    END
    ${response}=    POST
    ...    url=${url}/${ENTITIES_ENDPOINT_PATH}
    ...    json=${entity}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}    Create Entity Selecting Content Type
    RETURN    ${response}

Delete Entity Attributes
    [Arguments]    ${entityId}    ${attributeId}    ${datasetId}    ${deleteAll}    ${context}=${EMPTY}
    &{headers}=    Create Dictionary    Content-Type=${CONTENT_TYPE_JSON}
    IF    '${context}'!='${EMPTY}'
        Set To Dictionary
        ...    ${headers}
        ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    END
    @{params}=    Create List
    IF    '${datasetId}'!=''
        Append To List    ${params}    datasetId=${datasetId}
    END
    IF    '${deleteAll}'!=''
        Append To List    ${params}    deleteAll=${deleteAll}
    END
    ${params_as_string}=    Catenate    SEPARATOR=&    @{params}
    ${response}=    DELETE
    ...    url=${url}/${ENTITIES_ENDPOINT_PATH}${entityId}/attrs/${attributeId}?${params_as_string}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}    Delete Entity Attributes
    RETURN    ${response}

Delete Entity by Id
    [Arguments]    ${id}
    ${response}=    DELETE    url=${url}/${ENTITIES_ENDPOINT_PATH}${id}    expected_status=any
    Output    ${response}    Delete Entity by Id
    RETURN    ${response}

Delete Entity by Id Returning Response
    [Arguments]    ${id}
    ${response}=    DELETE    url=${url}/${ENTITIES_ENDPOINT_PATH}${id}    expected_status=any
    Output    ${response}    Delete Entity by Id Returning Response
    RETURN    ${response}

Partial Update Entity Attributes
    [Arguments]
    ...    ${entityId}
    ...    ${attributeId}
    ...    ${fragment_filename}
    ...    ${content_type}
    ...    ${accept}=${EMPTY}
    ...    ${context}=${EMPTY}
    &{headers}=    Create Dictionary    Content-Type=${content_type}
    IF    '${accept}'!=''
        Set To Dictionary    ${headers}    Accept    ${accept}
    END
    IF    '${context}'!=''
        Set To Dictionary
        ...    ${headers}
        ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    END
    ${fragment_payload}=    Load JSON From File    ${EXECDIR}/data/entities/fragmentEntities/${fragment_filename}
    ${response}=    PATCH
    ...    url=${url}/${ENTITIES_ENDPOINT_PATH}${entityId}/attrs/${attributeId}
    ...    json=${fragment_payload}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}    Partial Update Entity Attributes
    RETURN    ${response}

Query Entities
    [Arguments]
    ...    ${entity_ids}=${EMPTY}
    ...    ${entity_types}=${EMPTY}
    ...    ${accept}=${EMPTY}
    ...    ${attrs}=${EMPTY}
    ...    ${context}=${EMPTY}
    ...    ${geoproperty}=${EMPTY}
    ...    ${options}=${EMPTY}
    ...    ${limit}=${EMPTY}
    ...    ${entity_id_pattern}=${EMPTY}
    ...    ${georel}=${EMPTY}
    ...    ${coordinates}=${EMPTY}
    ...    ${geometry}=${EMPTY}
    ${attrs_length}=    Get Length    ${attrs}
    ${accept_length}=    Get Length    ${accept}
    ${options_length}=    Get Length    ${options}
    ${entity_ids_length}=    Get Length    ${entity_ids}
    ${entity_types_length}=    Get Length    ${entity_types}
    &{headers}=    Create Dictionary
    &{params}=    Create Dictionary
    IF    ${accept_length}>0
        Set To Dictionary    ${headers}    Accept    ${accept}
    END
    IF    '${context}'!=''
        Set To Dictionary
        ...    ${headers}
        ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    END
    IF    ${attrs_length}>0    Set To Dictionary    ${params}    attrs=${attrs}
    IF    '${geoproperty}'!=''
        Set To Dictionary    ${params}    geoproperty=${geoproperty}
    END
    IF    ${options_length}>0
        Set To Dictionary    ${params}    options=${options}
    END
    IF    ${entity_ids_length}>0
        Set To Dictionary    ${params}    id=${entity_ids}
    END
    IF    ${entity_types_length}>0
        Set To Dictionary    ${params}    type=${entity_types}
    END
    IF    '${limit}'!=''    Set To Dictionary    ${params}    limit=${limit}
    IF    '${entity_id_pattern}'!=''
        Set To Dictionary    ${params}    idPattern=${entity_id_pattern}
    END
    IF    '${georel}'!=''    Set To Dictionary    ${params}    georel=${georel}
    IF    '${coordinates}'!=''
        Set To Dictionary    ${params}    coordinates=${coordinates}
    END
    IF    '${geometry}'!=''
        Set To Dictionary    ${params}    geometry=${geometry}
    END

    ${response}=    GET
    ...    url=${url}/${ENTITIES_ENDPOINT_PATH}
    ...    headers=${headers}
    ...    params=${params}
    ...    expected_status=any
    Output    ${response}    Query Entities
    RETURN    ${response}

Retrieve Entity by Id
    [Arguments]    ${id}    ${accept}=${CONTENT_TYPE_LD_JSON}    ${context}=${EMPTY}
    ${headers}=    Create Dictionary
    Set To Dictionary    ${headers}    Accept    ${accept}
    IF    '${context}'!=''
        Set To Dictionary
        ...    ${headers}
        ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    END
    ${response}=    GET    url=${url}/${ENTITIES_ENDPOINT_PATH}${id}    headers=${headers}    expected_status=any
    Output    ${response}    Retrieve Entity by Id
    RETURN    ${response}

Request Entity From File
    [Arguments]    ${filename}
    ${file_content}=    Get File    ${EXECDIR}/data/entities/${filename}
    &{headers}=    Create Dictionary    Content-Type=application/ld+json
    ${response}=    POST
    ...    url=${url}/${ENTITIES_ENDPOINT_PATH}
    ...    data=${file_content}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}    Request Entity From File
    RETURN    ${response}

Update Entity Attributes
    [Arguments]    ${id}    ${fragment_filename}    ${content_type}
    &{headers}=    Create Dictionary    Content-Type=${content_type}
    ${file_content}=    Get File    ${EXECDIR}/data/entities/fragmentEntities/${fragment_filename}
    ${response}=    PATCH
    ...    url=${url}/${ENTITIES_ENDPOINT_PATH}${id}/attrs/
    ...    data=${file_content}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}    Update Entity Attributes
    RETURN    ${response}
