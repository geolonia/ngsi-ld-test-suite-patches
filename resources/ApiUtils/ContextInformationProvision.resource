*** Settings ***
Variables       ${EXECDIR}/resources/variables.py
Library         ${EXECDIR}/libraries/logUtils.py
Library         RequestsLibrary
Library         OperatingSystem
Library         Collections
Library         JSONLibrary
Resource        ${EXECDIR}/resources/ApiUtils/TemporalContextInformationProvision.resource
Resource        ${EXECDIR}/resources/JsonUtils.resource


*** Variables ***
${BATCH_CREATE_ENDPOINT_PATH}               entityOperations/create
${BATCH_DELETE_ENDPOINT_PATH}               entityOperations/delete
${BATCH_UPDATE_ENDPOINT_PATH}               entityOperations/update
${BATCH_UPSERT_ENDPOINT_PATH}               entityOperations/upsert
${BATCH_MERGE_ENDPOINT_PATH}                entityOperations/merge
&{BATCH_OPERATION_ENDPOINT_MAPPING}         &{EMPTY}
 ...                                        create=${BATCH_CREATE_ENDPOINT_PATH}
 ...                                        delete=${BATCH_DELETE_ENDPOINT_PATH}
 ...                                        update=${BATCH_UPDATE_ENDPOINT_PATH}
 ...                                        upsert=${BATCH_UPSERT_ENDPOINT_PATH}
 ...                                        merge=${BATCH_MERGE_ENDPOINT_PATH}

${ENTITIES_ENDPOINT_PATH}                   entities/

${BUILDING_ID_PREFIX}                       urn:ngsi-ld:Building:

${CONTENT_TYPE_JSON}                        application/json
${CONTENT_TYPE_LD_JSON}                     application/ld+json
${CONTENT_TYPE_MERGE_PATCH_JSON}            application/merge-patch+json

${ERROR_TYPE_BAD_REQUEST_DATA}              https://uri.etsi.org/ngsi-ld/errors/BadRequestData
${ERROR_TYPE_LD_CONTEXT_NOT_AVAILABLE}      https://uri.etsi.org/ngsi-ld/errors/LdContextNotAvailable
${ERROR_TYPE_ALREADY_EXISTS}                https://uri.etsi.org/ngsi-ld/errors/AlreadyExists
${ERROR_TYPE_INVALID_REQUEST}               https://uri.etsi.org/ngsi-ld/errors/InvalidRequest
${ERROR_TYPE_RESOURCE_NOT_FOUND}            https://uri.etsi.org/ngsi-ld/errors/ResourceNotFound

${response}                                 ${EMPTY}


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
    [Arguments]    ${entities_ids_to_be_deleted}    ${teardown}=False
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
    [Arguments]    @{entities_to_be_updated}    ${overwrite_option}=${EMPTY}
    @{params}=    Create List
    IF    '${overwrite_option}'!=''
        Append To List    ${params}    options=${overwrite_option}
    END
    ${params_as_string}=    Catenate    SEPARATOR=&    @{params}
    &{headers}=    Create Dictionary    Content-Type=application/ld+json
    ${response}=    POST
    ...    url=${url}/${BATCH_UPDATE_ENDPOINT_PATH}?${params_as_string}
    ...    json=@{entities_to_be_updated}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}    Batch Update Entities
    RETURN    ${response}

Batch Merge Entities
    [Arguments]    @{entities_to_be_merged}
    &{headers}=    Create Dictionary    Content-Type=application/ld+json
    ${response}=    POST
    ...    url=${url}/${BATCH_MERGE_ENDPOINT_PATH}
    ...    json=@{entities_to_be_merged}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}    Batch Merge Entities
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

Create Entity selecting @context
    [Arguments]    ${filename}    ${context}    ${entity_id}=${EMPTY}
    ${entity_payload}=    Load JSON From File    ${EXECDIR}/data/jsonldContext/${filename}
    ${entity}=    Update Value To JSON    ${entity_payload}    $..@context    ${context}

    IF    '${entity_id}'!=''
        ${entity}=    Update Value To JSON    ${entity}    $..id    ${entity_id}
    END

    &{headers}=    Create Dictionary    Content-Type=application/ld+json
    ${response}=    POST
    ...    url=${url}/${ENTITIES_ENDPOINT_PATH}
    ...    json=${entity}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}    Create Entity selecting @context
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

Create Entity From File
    [Arguments]    ${filename}
    ${file_content}=    Get File    ${EXECDIR}/data/entities/${filename}
    &{headers}=    Create Dictionary    Content-Type=application/ld+json
    ${response}=    POST
    ...    url=${url}/${ENTITIES_ENDPOINT_PATH}
    ...    data=${file_content}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}    Create Entity From File
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
    ${response}=    DELETE
    ...    url=${url}/${ENTITIES_ENDPOINT_PATH}${id}
    ...    expected_status=any
    IF    ${delete_temporal_on_core_delete}
        Delete Temporal Representation Of Entity    ${id}
    END
    Output    ${response}    Delete Entity by Id
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

Replace Entity
    [Arguments]
    ...    ${entity_id}
    ...    ${filename}
    ...    ${content_type}
    ...    ${context}=${EMPTY}
    ${entity}=    Load Entity
    ...    entity_file_name=${filename}
    ...    entity_id=${entity_id}
    &{headers}=    Create Dictionary    Content-Type=${content_type}
    IF    '${context}'!=''
        Set To Dictionary
        ...    ${headers}
        ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    END
    ${response}=    PUT
    ...    url=${url}/${ENTITIES_ENDPOINT_PATH}${entity_id}
    ...    headers=${headers}
    ...    json=${entity}
    ...    expected_status=any
    Output    ${response}    Replace Entity
    RETURN    ${response}

Replace Entity Selecting Content Type
    [Arguments]
    ...    ${entity_id}
    ...    ${entity_fragment}
    ...    ${content_type}
    ...    ${context}=${EMPTY}
    &{headers}=    Create Dictionary    Content-Type=${content_type}
    IF    '${context}'!=''
        Set To Dictionary
        ...    ${headers}
        ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    END
    ${response}=    PUT
    ...    url=${url}/${ENTITIES_ENDPOINT_PATH}${entity_id}
    ...    headers=${headers}
    ...    json=${entity_fragment}
    ...    expected_status=any
    Output    ${response}    Replace Entity Selecting Content Type
    RETURN    ${response}

Merge Entity
    [Arguments]
    ...    ${entity_id}
    ...    ${entity_filename}
    ...    ${content_type}
    ...    ${context}=${EMPTY}
    ${entity_payload}=    Load JSON From File    ${EXECDIR}/data/entities/${entity_filename}
    ${entity}=    Update Value To JSON    ${entity_payload}    $.id    ${entity_id}
    &{headers}=    Create Dictionary    Content-Type=${content_type}
    IF    '${context}'!=''
        Set To Dictionary
        ...    ${headers}
        ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    END
    ${response}=    PATCH
    ...    url=${url}/${ENTITIES_ENDPOINT_PATH}${entity_id}
    ...    headers=${headers}
    ...    json=${entity}
    ...    expected_status=any
    Output    ${response}    Merge Entity
    RETURN    ${response}

Replace Attribute Selecting Content Type
    [Arguments]
    ...    ${entity_id}
    ...    ${attr_id}
    ...    ${attribute_fragment}
    ...    ${content_type}
    ...    ${context}=${EMPTY}
    &{headers}=    Create Dictionary    Content-Type=${content_type}
    IF    '${context}'!=''
        Set To Dictionary
        ...    ${headers}
        ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    END
    ${response}=    PUT
    ...    url=${url}/${ENTITIES_ENDPOINT_PATH}${entity_id}/attrs/${attr_id}
    ...    headers=${headers}
    ...    json=${attribute_fragment}
    ...    expected_status=any
    Output    ${response}    Replace Attribute Selecting Content Type
    RETURN    ${response}
