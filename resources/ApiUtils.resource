*** Settings ***
Variables       ./variables.py
Library         ${EXECDIR}/libraries/logUtils.py
Library         RequestsLibrary
Library         OperatingSystem
Library         Collections
Library         JSONLibrary


*** Variables ***
${BATCH_CREATE_ENDPOINT_PATH}                                   entityOperations/create
${BATCH_UPSERT_ENDPOINT_PATH}                                   entityOperations/upsert
${BATCH_UPDATE_ENDPOINT_PATH}                                   entityOperations/update
${BATCH_DELETE_ENDPOINT_PATH}                                   entityOperations/delete
&{BATCH_OPERATION_ENDPOINT_MAPPING}
...                                                             create=${BATCH_CREATE_ENDPOINT_PATH}
...                                                             upsert=${BATCH_UPSERT_ENDPOINT_PATH}
...                                                             update=${BATCH_UPDATE_ENDPOINT_PATH}
...                                                             delete=${BATCH_DELETE_ENDPOINT_PATH}
${ENTITIES_ENDPOINT_PATH}                                       entities/
${ENTITIES_TYPES_ENDPOINT_PATH}                                 types
${ATTRIBUTES_ENDPOINT_PATH}                                     attributes
${ENTITY_OPERATIONS_QUERY_ENDPOINT_PATH}                        entityOperations/query
${TEMPORAL_ENTITIES_ENDPOINT_PATH}                              temporal/entities
${TEMPORAL_ENTITY_OPERATIONS_ENDPOINT_PATH}                     temporal/entityOperations
${CONTEXT_SOURCE_REGISTRATION_ENDPOINT_PATH}                    csourceRegistrations
${SUBSCRIPTION_ENDPOINT_PATH}                                   subscriptions/
${CONTEXT_SOURCE_REGISTRATION_SUBSCRIPTION_ENDPOINT_PATH}       csourceSubscriptions

${CONTENT_TYPE_JSON}                                            application/json
${CONTENT_TYPE_LD_JSON}                                         application/ld+json
${CONTENT_TYPE_MERGE_PATCH_JSON}                                application/merge-patch+json

${ERROR_TYPE_BAD_REQUEST_DATA}                                  https://uri.etsi.org/ngsi-ld/errors/BadRequestData
${ERROR_TYPE_INVALID_REQUEST}                                   https://uri.etsi.org/ngsi-ld/errors/InvalidRequest
${ERROR_TYPE_RESOURCE_NOT_FOUND}                                https://uri.etsi.org/ngsi-ld/errors/ResourceNotFound
${ERROR_TYPE_ALREADY_EXISTS}                                    https://uri.etsi.org/ngsi-ld/errors/AlreadyExists
${ERROR_TYPE_LD_CONTEXT_NOT_AVAILABLE}                          https://uri.etsi.org/ngsi-ld/errors/LdContextNotAvailable

${response}                                                     ${EMPTY}


*** Keywords ***
Delete Entity by Id Returning Response
    [Arguments]    ${id}
    ${response}=    DELETE    url=${url}/${ENTITIES_ENDPOINT_PATH}${id}    expected_status=any
    Output    ${response}
    RETURN    ${response}

Delete Entity by Id
    [Arguments]    ${id}
    ${response}=    DELETE    url=${url}/${ENTITIES_ENDPOINT_PATH}${id}    expected_status=any
    Output    ${response}
    RETURN    ${response}

Query Entity
    [Arguments]
    ...    ${id}
    ...    ${accept}=${EMPTY}
    ...    ${attrs}=${EMPTY}
    ...    ${context}=${EMPTY}
    ...    ${geoproperty}=${EMPTY}
    ...    ${options}=${EMPTY}
    ${attrs_length}=    Get Length    ${attrs}
    ${accept_length}=    Get Length    ${accept}
    ${options_length}=    Get Length    ${options}
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

    ${response}=    GET
    ...    url=${url}/${ENTITIES_ENDPOINT_PATH}${id}
    ...    headers=${headers}
    ...    params=${params}
    ...    expected_status=any
    Set Test Variable    ${response}
    Output    ${response}
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
    Set Test Variable    ${response}
    Output    ${response}
    RETURN    ${response}

Query Entities Via POST
    [Arguments]
    ...    ${entity_ids}=${EMPTY}
    ...    ${entity_types}=${EMPTY}
    ...    ${content_type}=${CONTENT_TYPE_LD_JSON}
    ...    ${attrs}=${EMPTY}
    ...    ${entity_id_pattern}=${EMPTY}
    ...    ${geoproperty}=${EMPTY}
    &{headers}=    Create Dictionary
    &{params}=    Create Dictionary
    ${entity_ids_length}=    Get Length    ${entity_ids}
    ${entity_types_length}=    Get Length    ${entity_types}
    ${attrs_length}=    Get Length    ${attrs}
    Set To Dictionary    ${headers}    Content-Type    ${content_type}
    IF    ${entity_ids_length}>0
        Set To Dictionary    ${params}    id=${entity_ids}
    END
    IF    ${entity_types_length}>0
        Set To Dictionary    ${params}    type=${entity_types}
    END
    IF    ${attrs_length}>0    Set To Dictionary    ${params}    attrs=${attrs}
    IF    '${entity_id_pattern}'!=''
        Set To Dictionary    ${params}    idPattern=${entity_id_pattern}
    END
    IF    '${geoproperty}'!=''
        Set To Dictionary    ${params}    geoproperty=${geoproperty}
    END
    ${response}=    POST
    ...    url=${ENTITY_OPERATIONS_QUERY_ENDPOINT_PATH}
    ...    json=${params}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}
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
    Set Test Variable    ${response}
    Output    ${response}
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
    Output    ${response}
    RETURN    ${response}

Append Entity Attributes
    [Arguments]    ${id}    ${fragment_filename}    ${content_type}
    &{headers}=    Create Dictionary    Content-Type=${content_type}
    ${file_content}=    Get File    ${EXECDIR}/data/entities/fragmentEntities/${fragment_filename}
    ${response}=    POST
    ...    url=${url}/${ENTITIES_ENDPOINT_PATH}${id}/attrs/
    ...    data=${file_content}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}
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
    Output    ${response}
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
    Output    ${response}
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
    Output    ${response}
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
    Output    ${response}
    RETURN    ${response}

Retrieve Entity Types
    [Arguments]    ${context}=${EMPTY}    ${details}=${FALSE}    ${accept}=${EMPTY}

    &{headers}=    Create Dictionary
    &{params}=    Create Dictionary
    IF    '${accept}'!=''
        Set To Dictionary    ${headers}    Accept    ${accept}
    END
    IF    '${context}'!=''
        Set To Dictionary
        ...    ${headers}
        ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    END
    IF    ${details}    Set To Dictionary    ${params}    details=${details}
    ${response}=    GET
    ...    url=${url}/${ENTITIES_TYPES_ENDPOINT_PATH}/
    ...    headers=${headers}
    ...    params=${params}
    ...    expected_status=any
    Set Test Variable    ${response}
    Output    ${response}
    RETURN    ${response}

Retrieve Entity Type
    [Arguments]    ${type}    ${context}=${EMPTY}    ${accept}=${EMPTY}

    &{headers}=    Create Dictionary
    IF    '${accept}'!=''
        Set To Dictionary    ${headers}    Accept    ${accept}
    END
    IF    '${context}'!=''
        Set To Dictionary
        ...    ${headers}
        ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    END
    ${response}=    GET
    ...    url=${url}/${ENTITIES_TYPES_ENDPOINT_PATH}/${type}
    ...    headers=${headers}
    ...    expected_status=any
    Set Test Variable    ${response}
    Output    ${response}
    RETURN    ${response}

Retrieve Attributes
    [Arguments]    ${context}=${EMPTY}    ${details}=${FALSE}    ${accept}=${EMPTY}

    &{headers}=    Create Dictionary
    &{params}=    Create Dictionary
    IF    '${accept}'!=''
        Set To Dictionary    ${headers}    Accept    ${accept}
    END
    IF    '${context}'!=''
        Set To Dictionary
        ...    ${headers}
        ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    END
    IF    ${details}    Set To Dictionary    ${params}    details=${details}
    ${response}=    GET
    ...    url=${url}/${ATTRIBUTES_ENDPOINT_PATH}
    ...    headers=${headers}
    ...    params=${params}
    ...    expected_status=any
    Set Test Variable    ${response}
    Output    ${response}
    RETURN    ${response}

Retrieve Attribute
    [Arguments]    ${attribute_name}    ${context}=${EMPTY}    ${accept}=${EMPTY}

    &{headers}=    Create Dictionary
    IF    '${accept}'!=''
        Set To Dictionary    ${headers}    Accept    ${accept}
    END
    IF    '${context}'!=''
        Set To Dictionary
        ...    ${headers}
        ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    END
    ${response}=    GET
    ...    url=${url}/${ATTRIBUTES_ENDPOINT_PATH}/${attribute_name}
    ...    headers=${headers}
    ...    expected_status=any
    Set Test Variable    ${response}
    Output    ${response}
    RETURN    ${response}

Create Context Source Registration With Return
    [Arguments]    ${payload}    ${content_type}=${CONTENT_TYPE_LD_JSON}    ${context}=${EMPTY}    ${accept}=${EMPTY}
    &{headers}=    Create Dictionary    Content-Type=${content_type}
    IF    '${accept}'!=''
        Set To Dictionary    ${headers}    Accept=${context}
    END
    IF    '${context}'!=''
        Set To Dictionary
        ...    ${headers}
        ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    END
    ${response}=    POST
    ...    url=${url}/${CONTEXT_SOURCE_REGISTRATION_ENDPOINT_PATH}
    ...    json=${payload}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}
    RETURN    ${response}

Update Context Source Registration With Return
    [Arguments]    ${registration_id}    ${fragment}    ${content_type}    ${accept}=${EMPTY}
    &{headers}=    Create Dictionary    Content-Type=${content_type}
    IF    '${accept}'!=''    Set To Dictionary    ${headers}    Accept=${accept}
    ${response}=    PATCH
    ...    url=${url}/${CONTEXT_SOURCE_REGISTRATION_ENDPOINT_PATH}/${registration_id}
    ...    json=${fragment}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}
    RETURN    ${response}

Delete Context Source Registration With Return
    [Arguments]    ${registration_id}
    ${response}=    DELETE
    ...    url=${url}/${CONTEXT_SOURCE_REGISTRATION_ENDPOINT_PATH}/${registration_id}
    ...    expected_status=any
    Output    ${response}
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
    Output    ${response}
    RETURN    ${response}

Create Or Update Temporal Representation Of Entity Selecting Content Type
    [Arguments]    ${temporal_entity_representation_id}    ${filename}    ${content_type}    ${accept}=${EMPTY}
    ${temporal_entity_representation_payload}=    Load JSON From File    ${EXECDIR}/data/temporalEntities/${filename}
    ${temporal_entity_representation}=    Update Value To JSON
    ...    ${temporal_entity_representation_payload}
    ...    $..id
    ...    ${temporal_entity_representation_id}
    &{headers}=    Create Dictionary    Content-Type=${content_type}
    IF    '${accept}'!=''
        Set To Dictionary    ${headers}    Accept    ${accept}
    END
    ${response}=    POST
    ...    url=${url}/${TEMPORAL_ENTITIES_ENDPOINT_PATH}/
    ...    json=${temporal_entity_representation}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}
    RETURN    ${response}

Create Temporal Representation Of Entity Selecting Content Type
    [Arguments]    ${filename}    ${content_type}
    ${file_content}=    Get File    ${EXECDIR}/data/temporalEntities/${filename}
    &{headers}=    Create Dictionary    Content-Type=${content_type}
    ${response}=    POST
    ...    url=${url}/${TEMPORAL_ENTITIES_ENDPOINT_PATH}
    ...    data=${file_content}
    ...    headers=${headers}
    ...    expected_status=any
    Set Test Variable    ${response}
    Output    ${response}
    RETURN    ${response}

Append Attribute To Temporal Entity
    [Arguments]    ${temporal_entity_id}    ${fragment_filename}    ${content_type}
    &{headers}=    Create Dictionary    Content-Type=${content_type}
    ${file_content}=    Get File    ${EXECDIR}/data/temporalEntities/fragments/${fragment_filename}
    ${response}=    POST
    ...    url=${url}/${TEMPORAL_ENTITIES_ENDPOINT_PATH}/${temporal_entity_id}/attrs
    ...    data=${file_content}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}
    RETURN    ${response}

Modify Attribute Instance From Temporal Entity
    [Arguments]
    ...    ${temporal_entity_id}
    ...    ${attributeId}
    ...    ${instanceId}
    ...    ${fragment_filename}
    ...    ${content_type}
    ...    ${context}=${EMPTY}
    &{headers}=    Create Dictionary    Content-Type=${content_type}
    IF    '${context}'!=''
        Set To Dictionary
        ...    ${headers}
        ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    END
    ${fragment_payload}=    Load JSON From File    ${EXECDIR}/data/temporalEntities/fragments/${fragment_filename}
    ${response}=    PATCH
    ...    url=${url}/${TEMPORAL_ENTITIES_ENDPOINT_PATH}/${temporal_entity_id}/attrs/${attributeId}/${instanceId}
    ...    json=${fragment_payload}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}
    RETURN    ${response}

Delete Attribute From Temporal Entity
    [Arguments]
    ...    ${entityId}
    ...    ${attributeId}
    ...    ${content_type}
    ...    ${datasetId}
    ...    ${deleteAll}
    ...    ${context}=${EMPTY}
    &{headers}=    Create Dictionary    Content-Type=${content_type}
    IF    '${context}'!=''
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
    ...    url=${url}/${TEMPORAL_ENTITIES_ENDPOINT_PATH}/${entityId}/attrs/${attributeId}?${params_as_string}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}
    RETURN    ${response}

Delete Temporal Representation Of Entity With Returning Response
    [Arguments]    ${temporal_entity_representation_id}
    ${response}=    DELETE
    ...    url=${url}/${TEMPORAL_ENTITIES_ENDPOINT_PATH}/${temporal_entity_representation_id}
    ...    expected_status=any
    Output    ${response}
    RETURN    ${response}

Get Temporal Representation Of Entity
    [Arguments]
    ...    ${temporal_entity_representation_id}
    ...    ${accept}=${EMPTY}
    ...    ${options}=${EMPTY}
    ...    ${context}=${EMPTY}
    &{headers}=    Create Dictionary
    &{params}=    Create Dictionary
    ${options_length}=    Get Length    ${options}
    IF    '${accept}'!=''
        Set To Dictionary    ${headers}    Accept    ${accept}
    END
    IF    '${context}'!=''
        Set To Dictionary
        ...    ${headers}
        ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    END
    IF    ${options_length}>0
        Set To Dictionary    ${params}    options=${options}
    END
    ${response}=    GET
    ...    url=${url}/${TEMPORAL_ENTITIES_ENDPOINT_PATH}/${temporal_entity_representation_id}
    ...    headers=${headers}
    ...    params=${params}
    ...    expected_status=any
    Output    ${response}
    RETURN    ${response}

Delete Attribute Instance From Temporal Entity
    [Arguments]    ${temporal_entity_id}    ${attributeId}    ${instanceId}    ${content_type}    ${context}=${EMPTY}
    &{headers}=    Create Dictionary
    IF    '${context}'!=''
        Set To Dictionary
        ...    ${headers}
        ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    END
    ${response}=    DELETE
    ...    url=${url}/${TEMPORAL_ENTITIES_ENDPOINT_PATH}/${temporal_entity_id}/attrs/${attributeId}/${instanceId}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}
    RETURN    ${response}

Update Temporal Representation Of Entity Selecting Content Type
    [Arguments]
    ...    ${temporal_entity_representation_id}
    ...    ${attrId}
    ...    ${instanceId}
    ...    ${fragment_filename}
    ...    ${content_type}
    ${temporal_entity_fragment}=    Load JSON From File
    ...    ${EXECDIR}/data/temporalEntities/fragments/${fragment_filename}
    &{headers}=    Create Dictionary    Content-Type=${content_type}
    ${response}=    PATCH
    ...    url=${url}/${TEMPORAL_ENTITIES_ENDPOINT_PATH}/${temporal_entity_representation_id}/attrs/${attrId}/${instanceId}
    ...    json=${temporal_entity_fragment}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}
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
    Set Test Variable    ${response}
    Output    ${response}
    RETURN    ${response}

Batch Upsert Entities
    [Arguments]    @{entities_to_be_upserted}    ${update_option}=replace
    &{headers}=    Create Dictionary    Content-Type=application/ld+json
    ${response}=    POST
    ...    url=${url}/${BATCH_UPSERT_ENDPOINT_PATH}?options=${update_option}
    ...    json=@{entities_to_be_upserted}
    ...    headers=${headers}
    ...    expected_status=any
    Set Test Variable    ${response}
    Output    ${response}
    RETURN    ${response}

Batch Update Entities
    [Arguments]    @{entities_to_be_updated}    ${overwrite_option}=overwrite
    &{headers}=    Create Dictionary    Content-Type=application/ld+json
    ${response}=    POST
    ...    url=${url}/${BATCH_UPDATE_ENDPOINT_PATH}?options=${overwrite_option}
    ...    json=@{entities_to_be_updated}
    ...    headers=${headers}
    ...    expected_status=any
    Set Test Variable    ${response}
    Output    ${response}
    RETURN    ${response}

Batch Delete Entities
    [Arguments]    @{entities_ids_to_be_deleted}    ${teardown}=False
    &{headers}=    Create Dictionary    Content-Type=application/ld+json
    ${response}=    POST
    ...    url=${url}/${BATCH_DELETE_ENDPOINT_PATH}
    ...    json=@{entities_ids_to_be_deleted}
    ...    headers=${headers}
    ...    expected_status=any
    IF    not ${teardown}    Set Test Variable    ${response}
    Output    ${response}
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
    Set Test Variable    ${response}
    Output    ${response}
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
    Set Test Variable    ${response}
    Output    ${response}
    RETURN    ${response}

Create Temporal Representation Of Entity
    [Arguments]    ${filename}    ${temporal_entity_representation_id}
    ${temporal_entity_representation_payload}=    Load JSON From File    ${EXECDIR}/data/temporalEntities/${filename}
    ${temporal_entity_representation}=    Update Value To JSON
    ...    ${temporal_entity_representation_payload}
    ...    $..id
    ...    ${temporal_entity_representation_id}

    &{headers}=    Create Dictionary    Content-Type=application/ld+json
    ${response}=    POST
    ...    url=${url}/${TEMPORAL_ENTITIES_ENDPOINT_PATH}
    ...    json=${temporal_entity_representation}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}
    RETURN    ${response}

Retrieve Temporal Representation Of Entity
    [Arguments]
    ...    ${temporal_entity_representation_id}
    ...    ${attrs}=${EMPTY}
    ...    ${options}=${EMPTY}
    ...    ${context}=${EMPTY}
    ...    ${timerel}=${EMPTY}
    ...    ${timeAt}=${EMPTY}
    ...    ${endTimeAt}=${EMPTY}
    ...    ${lastN}=${EMPTY}
    ...    ${accept}=${EMPTY}
    ${attrs_length}=    Get Length    ${attrs}
    ${options_length}=    Get Length    ${options}
    &{headers}=    Create Dictionary
    &{params}=    Create Dictionary

    IF    '${accept}'!=''    Set To Dictionary    ${headers}    Accept=${accept}
    IF    '${context}'!=''
        Set To Dictionary
        ...    ${headers}
        ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    END
    IF    ${attrs_length}>0    Set To Dictionary    ${params}    attrs=${attrs}
    IF    ${options_length}>0
        Set To Dictionary    ${params}    options=${options}
    END
    IF    '${timerel}'!=''
        Set To Dictionary    ${params}    timerel=${timerel}
    END
    IF    '${timeAt}'!=''    Set To Dictionary    ${params}    timeAt=${timeAt}
    IF    '${endTimeAt}'!=''
        Set To Dictionary    ${params}    endTimeAt=${endTimeAt}
    END
    IF    '${lastN}'!=''    Set To Dictionary    ${params}    lastN=${lastN}

    ${response}=    GET
    ...    url=${url}/${TEMPORAL_ENTITIES_ENDPOINT_PATH}/${temporal_entity_representation_id}
    ...    headers=${headers}
    ...    params=${params}
    ...    expected_status=any
    Set Test Variable    ${response}
    Output    ${response}
    RETURN    ${response}

Query Temporal Representation Of Entities
    [Arguments]
    ...    ${context}=${EMPTY}
    ...    ${entity_types}=${EMPTY}
    ...    ${entity_ids}=${EMPTY}
    ...    ${entity_id_pattern}=${EMPTY}
    ...    ${ngsild_query}=${EMPTY}
    ...    ${csf}=${EMPTY}
    ...    ${georel}=${EMPTY}
    ...    ${geometry}=${EMPTY}
    ...    ${coordinates}=${EMPTY}
    ...    ${geoproperty}=${EMPTY}
    ...    ${timerel}=${EMPTY}
    ...    ${timeAt}=${EMPTY}
    ...    ${attrs}=${EMPTY}
    ...    ${limit}=${EMPTY}
    ...    ${lastN}=${EMPTY}
    ...    ${accept}=${EMPTY}
    ${entity_types_length}=    Get Length    ${entity_types}
    ${entity_ids_length}=    Get Length    ${entity_ids}
    ${attrs_length}=    Get Length    ${attrs}
    &{headers}=    Create Dictionary
    &{params}=    Create Dictionary
    IF    '${accept}'!=''    Set To Dictionary    ${headers}    Accept=${accept}
    IF    '${context}'!=''
        Set To Dictionary
        ...    ${headers}
        ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    END
    IF    ${entity_types_length}>0
        Set To Dictionary    ${params}    type=${entity_types}
    END
    IF    ${entity_ids_length}>0
        Set To Dictionary    ${params}    id=${entity_ids}
    END
    IF    '${timerel}'!=''
        Set To Dictionary    ${params}    timerel=${timerel}
    END
    IF    '${timeAt}'!=''    Set To Dictionary    ${params}    timeAt=${timeAt}
    IF    ${attrs_length}>0    Set To Dictionary    ${params}    attrs=${attrs}
    IF    '${lastN}'!=''    Set To Dictionary    ${params}    lastN=${lastN}
    IF    '${entity_id_pattern}'!=''
        Set To Dictionary    ${params}    idPattern=${entity_id_pattern}
    END
    IF    '${ngsild_query}'!=''
        Set To Dictionary    ${params}    q=${ngsild_query}
    END
    IF    '${csf}'!=''    Set To Dictionary    ${params}    csf=${csf}
    IF    '${georel}'!=''    Set To Dictionary    ${params}    georel=${georel}
    IF    '${geometry}'!=''
        Set To Dictionary    ${params}    geometry=${geometry}
    END
    IF    '${coordinates}'!=''
        Set To Dictionary    ${params}    coordinates=${coordinates}
    END
    IF    '${geoproperty}'!=''
        Set To Dictionary    ${params}    geoproperty=${geoproperty}
    END
    IF    '${limit}'!=''    Set To Dictionary    ${params}    limit=${limit}

    ${response}=    GET
    ...    url=${url}/${TEMPORAL_ENTITIES_ENDPOINT_PATH}
    ...    headers=${headers}
    ...    params=${params}
    ...    expected_status=any
    Set Test Variable    ${response}
    Output    ${response}
    RETURN    ${response}

Query Temporal Representation Of Entities Via Post
    [Arguments]    ${query_file_name}    ${content_type}=${CONTENT_TYPE_JSON}    ${context}=${EMPTY}
    ${headers}=    Create Dictionary
    Set To Dictionary    ${headers}    Content-Type    ${content_type}
    Set To Dictionary
    ...    ${headers}
    ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    ${query_payload}=    Load JSON From File    ${EXECDIR}/data/temporalEntities/${query_file_name}
    ${response}=    POST
    ...    url=${url}/${TEMPORAL_ENTITY_OPERATIONS_ENDPOINT_PATH}/query
    ...    json=${query_payload}
    ...    headers=${headers}
    ...    expected_status=any
    Set Test Variable    ${response}
    Output    ${response}
    RETURN    ${response}

Delete Temporal Representation Of Entity
    [Arguments]    ${temporal_entity_representation_id}

    ${response}=    DELETE
    ...    url=${url}/${TEMPORAL_ENTITIES_ENDPOINT_PATH}/${temporal_entity_representation_id}
    ...    expected_status=any
    Output    ${response}
    RETURN    ${response}

Create Context Source Registration
    [Arguments]    ${context_source_registration_payload}

    &{headers}=    Create Dictionary    Content-Type=application/ld+json
    ${response}=    POST
    ...    url=${url}/${CONTEXT_SOURCE_REGISTRATION_ENDPOINT_PATH}
    ...    json=${context_source_registration_payload}
    ...    headers=${headers}
    ...    expected_status=any
    Set Suite Variable    ${response}
    Output    ${response}
    RETURN    ${response}

Update Context Source Registration
    [Arguments]    ${context_source_registration_id}    ${update_fragment}

    ${response}=    PATCH
    ...    url=${url}/${CONTEXT_SOURCE_REGISTRATION_ENDPOINT_PATH}/${context_source_registration_id}
    ...    json=${update_fragment}
    ...    expected_status=any
    Set Test Variable    ${response}
    Output    ${response}
    RETURN    ${response}

Query Context Source Registrations
    [Arguments]
    ...    ${context}=${EMPTY}
    ...    ${id}=${EMPTY}
    ...    ${type}=${EMPTY}
    ...    ${attrs}=${EMPTY}
    ...    ${q}=${EMPTY}
    ...    ${csf}=${EMPTY}
    ...    ${georel}=${EMPTY}
    ...    ${geometry}=${EMPTY}
    ...    ${coordinates}=${EMPTY}
    ...    ${geoproperty}=${EMPTY}
    ...    ${timeproperty}=${EMPTY}
    ...    ${timerel}=${EMPTY}
    ...    ${timeAt}=${EMPTY}
    ...    ${limit}=${EMPTY}
    ...    ${page}=${EMPTY}
    ...    ${accept}=${EMPTY}

    &{headers}=    Create Dictionary
    &{params}=    Create Dictionary
    IF    '${context}'!=''
        Set To Dictionary
        ...    ${headers}
        ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    END
    IF    '${accept}'!=''    Set To Dictionary    ${headers}    Accept=${accept}
    IF    '${id}'!=''    Set To Dictionary    ${params}    id=${id}
    IF    '${type}'!=''    Set To Dictionary    ${params}    type=${type}
    IF    '${attrs}'!=''    Set To Dictionary    ${params}    attrs=${attrs}
    IF    '${q}'!=''    Set To Dictionary    ${params}    q=${q}
    IF    '${csf}'!=''    Set To Dictionary    ${params}    csf=${csf}
    IF    '${georel}'!=''    Set To Dictionary    ${params}    georel=${georel}
    IF    '${geometry}'!=''
        Set To Dictionary    ${params}    geometry=${geometry}
    END
    IF    '${coordinates}'!=''
        Set To Dictionary    ${params}    coordinates=${coordinates}
    END
    IF    '${geoproperty}'!=''
        Set To Dictionary    ${params}    geoproperty=${geoproperty}
    END
    IF    '${timeproperty}'!=''
        Set To Dictionary    ${params}    timeproperty=${timeproperty}
    END
    IF    '${timerel}'!=''
        Set To Dictionary    ${params}    timerel=${timerel}
    END
    IF    '${timeAt}'!=''    Set To Dictionary    ${params}    timeAt=${timeAt}
    IF    '${limit}'!=''    Set To Dictionary    ${params}    limit=${limit}
    IF    '${page}'!=''    Set To Dictionary    ${params}    page=${page}

    ${response}=    GET
    ...    url=${url}/${CONTEXT_SOURCE_REGISTRATION_ENDPOINT_PATH}
    ...    headers=${headers}
    ...    params=${params}
    ...    expected_status=any
    Set Test Variable    ${response}
    Output    ${response}
    RETURN    ${response}

Delete Context Source Registration
    [Arguments]    ${context_source_registration_id}

    ${response}=    DELETE    url=${url}/${CONTEXT_SOURCE_REGISTRATION_ENDPOINT_PATH}/${context_source_registration_id}
    Set Suite Variable    ${response}
    Output    ${response}
    RETURN    ${response}

Retrieve Context Source Registration
    [Arguments]    ${context_source_registration_id}    ${context}=${EMPTY}    ${accept}=${EMPTY}

    &{headers}=    Create Dictionary
    IF    '${accept}'!=''    Set To Dictionary    ${headers}    Accept=${accept}
    IF    '${context}'!=''
        Set To Dictionary
        ...    ${headers}
        ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    END
    ${response}=    GET
    ...    url=${url}/${CONTEXT_SOURCE_REGISTRATION_ENDPOINT_PATH}/${context_source_registration_id}
    ...    headers=${headers}
    ...    expected_status=any
    Set Test Variable    ${response}
    Output    ${response}
    RETURN    ${response}

Create Context Source Registration Subscription
    [Arguments]    ${subscription_payload}    ${accept}=${EMPTY}    ${content_type}=${CONTENT_TYPE_LD_JSON}

    &{headers}=    Create Dictionary    Content-Type=${content_type}
    IF    '${accept}'!=''
        Set To Dictionary    ${headers}    Accept    ${accept}
    END
    ${response}=    POST
    ...    url=${url}/${CONTEXT_SOURCE_REGISTRATION_SUBSCRIPTION_ENDPOINT_PATH}
    ...    json=${subscription_payload}
    ...    headers=${headers}
    ...    expected_status=any
    Set Suite Variable    ${response}
    Output    ${response}
    RETURN    ${response}

Update Context Source Registration Subscription
    [Arguments]    ${subscription_id}    ${subscription_update_fragment}

    ${response}=    PATCH
    ...    url=${url}/${CONTEXT_SOURCE_REGISTRATION_SUBSCRIPTION_ENDPOINT_PATH}/${subscription_id}
    ...    json=${subscription_update_fragment}
    ...    expected_status=any
    Set Test Variable    ${response}
    Output    ${response}
    RETURN    ${response}

Retrieve Context Source Registration Subscription
    [Arguments]    ${subscription_id}    ${context}=${EMPTY}    ${accept}=${CONTENT_TYPE_JSON}

    &{headers}=    Create Dictionary
    Set To Dictionary    ${headers}    Accept    ${accept}
    IF    '${context}'!=''
        Set To Dictionary
        ...    ${headers}
        ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    END
    ${response}=    GET
    ...    url=${url}/${CONTEXT_SOURCE_REGISTRATION_SUBSCRIPTION_ENDPOINT_PATH}/${subscription_id}
    ...    headers=${headers}
    ...    expected_status=any
    Set Test Variable    ${response}
    Output    ${response}
    RETURN    ${response}

Query Context Source Registration Subscriptions
    [Arguments]    ${context}=${EMPTY}    ${limit}=${EMPTY}    ${page}=${EMPTY}    ${accept}=${EMPTY}

    &{headers}=    Create Dictionary
    &{params}=    Create Dictionary
    IF    '${accept}'!=''    Set To Dictionary    ${headers}    Accept=${accept}
    IF    '${context}'!=''
        Set To Dictionary
        ...    ${headers}
        ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    END
    IF    '${limit}'!=''    Set To Dictionary    ${params}    limit=${limit}
    IF    '${page}'!=''    Set To Dictionary    ${params}    page=${page}

    ${response}=    GET
    ...    url=${url}/${CONTEXT_SOURCE_REGISTRATION_SUBSCRIPTION_ENDPOINT_PATH}
    ...    headers=${headers}
    ...    params=${params}
    ...    expected_status=any
    Set Test Variable    ${response}
    Output    ${response}
    RETURN    ${response}

Delete Context Source Registration Subscription
    [Arguments]    ${subscription_id}

    ${response}=    DELETE    ${url}/${CONTEXT_SOURCE_REGISTRATION_SUBSCRIPTION_ENDPOINT_PATH}/${subscription_id}
    Set Suite Variable    ${response}
    Output    ${response}
    RETURN    ${response}

Update Context Source Registration Subscription From File
    [Arguments]    ${subscription_id}    ${file_path}
    ${file_content}=    Get File    ${EXECDIR}/data/${file_path}
    ${response}=    PATCH
    ...    url=${url}/${CONTEXT_SOURCE_REGISTRATION_SUBSCRIPTION_ENDPOINT_PATH}/${subscription_id}
    ...    data=${file_content}
    ...    expected_status=any
    Set Test Variable    ${response}
    Output    ${response}
    RETURN    ${response}

Create Subscription
    [Arguments]
    ...    ${subscription_id}
    ...    ${filename_path}
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
    ${subscription_payload}=    Load JSON From File    ${EXECDIR}/data/${filename_path}
    ${subscription}=    Update Value To JSON    ${subscription_payload}    $..id    ${subscription_id}
    ${response}=    POST
    ...    url=${url}/${SUBSCRIPTION_ENDPOINT_PATH}
    ...    json=${subscription}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}
    RETURN    ${response}

Create Subscription From Subscription Payload
    [Arguments]
    ...    ${subscription_payload}
    ...    ${content_type}=${CONTENT_TYPE_LD_JSON}
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
    ${response}=    POST
    ...    url=${url}/${SUBSCRIPTION_ENDPOINT_PATH}
    ...    json=${subscription_payload}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}
    RETURN    ${response}

Create Subscription From File
    [Arguments]    ${filename}
    ${file_content}=    Get File    ${EXECDIR}/data/subscriptions/${filename}
    &{headers}=    Create Dictionary    Content-Type=application/ld+json
    ${response}=    POST
    ...    url=${url}/${SUBSCRIPTION_ENDPOINT_PATH}
    ...    data=${file_content}
    ...    headers=${headers}
    ...    expected_status=any
    Set Test Variable    ${response}
    Output    ${response}
    RETURN    ${response}

Update Subscription
    [Arguments]
    ...    ${subscription_id}
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
    ${subscription_update_fragment}=    Load JSON From File    ${EXECDIR}/data/${fragment_filename}
    ${response}=    PATCH
    ...    url=${url}/${SUBSCRIPTION_ENDPOINT_PATH}${subscription_id}
    ...    json=${subscription_update_fragment}
    ...    headers=${headers}
    ...    expected_status=any
    Set Test Variable    ${response}
    Output    ${response}
    RETURN    ${response}

Update Subscription With Payload
    [Arguments]    ${subscription_id}    ${payload}    ${content_type}    ${accept}=${EMPTY}    ${context}=${EMPTY}
    &{headers}=    Create Dictionary    Content-Type=${content_type}
    IF    '${accept}'!=''
        Set To Dictionary    ${headers}    Accept    ${accept}
    END
    IF    '${context}'!=''
        Set To Dictionary
        ...    ${headers}
        ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    END
    ${response}=    PATCH
    ...    url=${url}/${SUBSCRIPTION_ENDPOINT_PATH}${subscription_id}
    ...    json=${payload}
    ...    headers=${headers}
    ...    expected_status=any
    Set Test Variable    ${response}
    Output    ${response}
    RETURN    ${response}

Delete Subscription
    [Arguments]    ${subscription_id}
    ${response}=    DELETE    url=${url}/${SUBSCRIPTION_ENDPOINT_PATH}${subscription_id}    expected_status=any
    Set Suite Variable    ${response}
    Output    ${response}
    RETURN    ${response}

Query Subscriptions
    [Arguments]    ${context}=${EMPTY}    ${limit}=${EMPTY}    ${offset}=${EMPTY}    ${accept}=${EMPTY}

    &{headers}=    Create Dictionary
    &{params}=    Create Dictionary
    IF    '${context}'!=''
        Set To Dictionary
        ...    ${headers}
        ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    END
    IF    '${limit}'!=''    Set To Dictionary    ${params}    limit=${limit}
    IF    '${offset}'!=''    Set To Dictionary    ${params}    offset=${offset}
    IF    '${accept}'!=''
        Set To Dictionary    ${headers}    Accept    ${accept}
    END

    ${response}=    GET
    ...    url=${url}/${SUBSCRIPTION_ENDPOINT_PATH}
    ...    headers=${headers}
    ...    params=${params}
    ...    expected_status=any
    Set Test Variable    ${response}
    Output    ${response}
    RETURN    ${response}

Retrieve Subscription
    [Arguments]    ${id}    ${accept}=${EMPTY}    ${context}=${EMPTY}    ${content_type}=${CONTENT_TYPE_LD_JSON}

    &{headers}=    Create Dictionary    Content-Type=${content_type}
    IF    '${accept}'!=''
        Set To Dictionary    ${headers}    Accept    ${accept}
    END
    IF    '${context}'!=''
        Set To Dictionary
        ...    ${headers}
        ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    END

    ${response}=    GET    url=${url}/${SUBSCRIPTION_ENDPOINT_PATH}${id}    headers=${headers}    expected_status=any
    Set Test Variable    ${response}
    Output    ${response}
    RETURN    ${response}

Query Context Source Registrations With Return
    [Arguments]
    ...    ${context}=${EMPTY}
    ...    ${id}=${EMPTY}
    ...    ${type}=${EMPTY}
    ...    ${attrs}=${EMPTY}
    ...    ${q}=${EMPTY}
    ...    ${georel}=${EMPTY}
    ...    ${geometry}=${EMPTY}
    ...    ${coordinates}=${EMPTY}
    ...    ${geoproperty}=${EMPTY}
    ...    ${timeproperty}=${EMPTY}
    ...    ${timerel}=${EMPTY}
    ...    ${timeAt}=${EMPTY}
    ...    ${limit}=${EMPTY}
    ...    ${page}=${EMPTY}
    ...    ${accept}=${EMPTY}

    &{headers}=    Create Dictionary
    &{params}=    Create Dictionary
    IF    '${context}'!=''
        Set To Dictionary
        ...    ${headers}
        ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    END
    IF    '${accept}'!=''
        Set To Dictionary    ${headers}    Accept    ${accept}
    END
    IF    '${id}'!=''    Set To Dictionary    ${params}    id=${id}
    IF    '${type}'!=''    Set To Dictionary    ${params}    type=${type}
    IF    '${attrs}'!=''    Set To Dictionary    ${params}    attrs=${attrs}
    IF    '${q}'!=''    Set To Dictionary    ${params}    q=${q}
    IF    '${georel}'!=''    Set To Dictionary    ${params}    georel=${georel}
    IF    '${geometry}'!=''
        Set To Dictionary    ${params}    geometry=${geometry}
    END
    IF    '${coordinates}'!=''
        Set To Dictionary    ${params}    coordinates=${coordinates}
    END
    IF    '${geoproperty}'!=''
        Set To Dictionary    ${params}    geoproperty=${geoproperty}
    END
    IF    '${timeproperty}'!=''
        Set To Dictionary    ${params}    timeproperty=${timeproperty}
    END
    IF    '${timerel}'!=''
        Set To Dictionary    ${params}    timerel=${timerel}
    END
    IF    '${timeAt}'!=''    Set To Dictionary    ${params}    timeAt=${timeAt}
    IF    '${limit}'!=''    Set To Dictionary    ${params}    limit=${limit}
    IF    '${page}'!=''    Set To Dictionary    ${params}    page=${page}

    ${response}=    GET
    ...    url=${url}/${CONTEXT_SOURCE_REGISTRATION_ENDPOINT_PATH}
    ...    headers=${headers}
    ...    params=${params}
    ...    expected_status=any
    Output    ${response}
    RETURN    ${response}

Query Temporal Representation Of Entities With Return
    [Arguments]
    ...    ${context}=${EMPTY}
    ...    ${entity_types}=${EMPTY}
    ...    ${entity_ids}=${EMPTY}
    ...    ${entity_id_pattern}=${EMPTY}
    ...    ${ngsild_query}=${EMPTY}
    ...    ${csf}=${EMPTY}
    ...    ${georel}=${EMPTY}
    ...    ${geometry}=${EMPTY}
    ...    ${coordinates}=${EMPTY}
    ...    ${geoproperty}=${EMPTY}
    ...    ${timerel}=${EMPTY}
    ...    ${timeAt}=${EMPTY}
    ...    ${attrs}=${EMPTY}
    ...    ${limit}=${EMPTY}
    ...    ${lastN}=${EMPTY}
    ...    ${accept}=${EMPTY}
    ${entity_types_length}=    Get Length    ${entity_types}
    ${entity_ids_length}=    Get Length    ${entity_ids}
    ${attrs_length}=    Get Length    ${attrs}
    &{headers}=    Create Dictionary
    &{params}=    Create Dictionary
    IF    '${accept}'!=''    Set To Dictionary    ${headers}    Accept=${accept}
    IF    '${context}'!=''
        Set To Dictionary
        ...    ${headers}
        ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    END
    IF    ${entity_types_length}>0
        Set To Dictionary    ${params}    type=${entity_types}
    END
    IF    ${entity_ids_length}>0
        Set To Dictionary    ${params}    id=${entity_ids}
    END
    IF    '${timerel}'!=''
        Set To Dictionary    ${params}    timerel=${timerel}
    END
    IF    '${timeAt}'!=''    Set To Dictionary    ${params}    timeAt=${timeAt}
    IF    ${attrs_length}>0    Set To Dictionary    ${params}    attrs=${attrs}
    IF    '${lastN}'!=''    Set To Dictionary    ${params}    lastN=${lastN}
    IF    '${entity_id_pattern}'!=''
        Set To Dictionary    ${params}    idPattern=${entity_id_pattern}
    END
    IF    '${ngsild_query}'!=''
        Set To Dictionary    ${params}    q=${ngsild_query}
    END
    IF    '${csf}'!=''    Set To Dictionary    ${params}    csf=${csf}
    IF    '${georel}'!=''    Set To Dictionary    ${params}    georel=${georel}
    IF    '${geometry}'!=''
        Set To Dictionary    ${params}    geometry=${geometry}
    END
    IF    '${coordinates}'!=''
        Set To Dictionary    ${params}    coordinates=${coordinates}
    END
    IF    '${geoproperty}'!=''
        Set To Dictionary    ${params}    geoproperty=${geoproperty}
    END
    IF    '${limit}'!=''    Set To Dictionary    ${params}    limit=${limit}

    ${response}=    GET
    ...    url=${url}/${TEMPORAL_ENTITIES_ENDPOINT_PATH}
    ...    headers=${headers}
    ...    params=${params}
    ...    expected_status=any
    Output    ${response}
    RETURN    ${response}
