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
${ENTITIES_ENDPOINT_PATH}       entities/
${ENTITIES_TYPES_ENDPOINT_PATH}       types
${ATTRIBUTES_ENDPOINT_PATH}       attributes
${ENTITY_OPERATIONS_QUERY_ENDPOINT_PATH}    entityOperations/query
${TEMPORAL_ENTITIES_ENDPOINT_PATH}       temporal/entities
${TEMPORAL_ENTITY_OPERATIONS_ENDPOINT_PATH}       temporal/entityOperations
${CONTEXT_SOURCE_REGISTRATION_ENDPOINT_PATH}       csourceRegistrations
${SUBSCRIPTION_ENDPOINT_PATH}       subscriptions/
${CONTEXT_SOURCE_REGISTRATION_SUBSCRIPTION_ENDPOINT_PATH}       csourceSubscriptions

${CONTENT_TYPE_JSON}            application/json
${CONTENT_TYPE_LD_JSON}         application/ld+json
${CONTENT_TYPE_MERGE_PATCH_JSON}         application/merge-patch+json

${ERROR_TYPE_BAD_REQUEST_DATA}      https://uri.etsi.org/ngsi-ld/errors/BadRequestData
${ERROR_TYPE_INVALID_REQUEST}      https://uri.etsi.org/ngsi-ld/errors/InvalidRequest
${ERROR_TYPE_RESOURCE_NOT_FOUND}      https://uri.etsi.org/ngsi-ld/errors/ResourceNotFound
${ERROR_TYPE_ALREADY_EXISTS}      https://uri.etsi.org/ngsi-ld/errors/AlreadyExists
${ERROR_TYPE_LD_CONTEXT_NOT_AVAILABLE}     https://uri.etsi.org/ngsi-ld/errors/LDContextNotAvailable

${response}

*** Keywords ***
Delete Entity by Id Returning Response
    [Arguments]  ${id}
    ${response}=  DELETE  ${ENTITIES_ENDPOINT_PATH}${id}
    Output  request
    Output  response
    [return]  ${response}

Delete Entity by Id
    [Arguments]  ${id}
    ${response}=  DELETE  ${ENTITIES_ENDPOINT_PATH}${id}
    Output  request
    Output  response

Query Entity
    [Arguments]  ${id}     ${accept}=${EMPTY}    ${attrs}=${EMPTY}      ${context}=${EMPTY}    ${geoproperty}=${EMPTY}    ${options}=${EMPTY} 
    ${attrs_length} =  Get Length  ${attrs}
    ${accept_length} =  Get Length  ${accept}
    ${options_length} =  Get Length  ${options}
    &{headers}=  Create Dictionary
    &{params}=  Create Dictionary
    Run Keyword If     ${accept_length}>0       Set To Dictionary   ${headers}   Accept    ${accept}
    Run Keyword If     '${context}'!=''       Set To Dictionary   ${headers}    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type=${accept}
    Run Keyword If     ${attrs_length}>0       Set To Dictionary   ${params}       attrs=${attrs}
    Run Keyword If     '${geoproperty}'!=''       Set To Dictionary   ${params}    geoproperty=${geoproperty}
    Run Keyword If     ${options_length}>0       Set To Dictionary   ${params}       options=${options}
    
    ${response}=  GET  ${ENTITIES_ENDPOINT_PATH}${id}      headers=${headers}      query=${params}
    ${request}=    Output  request
    Output  response
    Set Test Variable  ${response}
    [return]  ${request}    ${response}

Query Entities
    [Arguments]  ${entity_ids}=${EMPTY}     ${entity_types}=${EMPTY}     ${accept}=${EMPTY}    ${attrs}=${EMPTY}      ${context}=${EMPTY}    ${geoproperty}=${EMPTY}    ${options}=${EMPTY}     ${limit}=${EMPTY}    ${entity_id_pattern}=${EMPTY}
    ${attrs_length} =  Get Length  ${attrs}
    ${accept_length} =  Get Length  ${accept}
    ${options_length} =  Get Length  ${options}
    ${entity_ids_length} =  Get Length  ${entity_ids}
    ${entity_types_length} =  Get Length  ${entity_types}
    &{headers}=  Create Dictionary
    &{params}=  Create Dictionary
    Run Keyword If     ${accept_length}>0       Set To Dictionary   ${headers}   Accept    ${accept}
    Run Keyword If     '${context}'!=''       Set To Dictionary   ${headers}    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type=${accept}
    Run Keyword If     ${attrs_length}>0       Set To Dictionary   ${params}       attrs=${attrs}
    Run Keyword If     '${geoproperty}'!=''       Set To Dictionary   ${params}    geoproperty=${geoproperty}
    Run Keyword If     ${options_length}>0       Set To Dictionary   ${params}       options=${options}
    Run Keyword If     ${entity_ids_length}>0       Set To Dictionary   ${params}    id=${entity_ids}
    Run Keyword If     ${entity_types_length}>0       Set To Dictionary   ${params}    type=${entity_types}
    Run Keyword If     '${limit}'!=''       Set To Dictionary   ${params}    limit=${limit}
    Run Keyword If     '${entity_id_pattern}'!=''       Set To Dictionary   ${params}    idPattern=${entity_id_pattern}

    ${response}=  GET  ${ENTITIES_ENDPOINT_PATH}      headers=${headers}      query=${params}
    Output  request
    Output  response
    Set Test Variable  ${response}
    [return]    ${response}

Query Entities Via POST
    [Arguments]  ${entity_ids}=${EMPTY}     ${entity_types}=${EMPTY}    ${content_type}=${CONTENT_TYPE_LD_JSON}    ${attrs}=${EMPTY}    ${entity_id_pattern}=${EMPTY}    ${geoproperty}=${EMPTY}
    &{headers}=  Create Dictionary
    &{params}=  Create Dictionary
    ${entity_ids_length} =  Get Length  ${entity_ids}
    ${entity_types_length} =  Get Length  ${entity_types}
    ${attrs_length} =  Get Length  ${attrs}
    Set To Dictionary   ${headers}   Content-Type    ${content_type}
    Run Keyword If     ${entity_ids_length}>0       Set To Dictionary   ${params}    id=${entity_ids}
    Run Keyword If     ${entity_types_length}>0       Set To Dictionary   ${params}    type=${entity_types}
    Run Keyword If     ${attrs_length}>0       Set To Dictionary   ${params}       attrs=${attrs}
    Run Keyword If     '${entity_id_pattern}'!=''       Set To Dictionary   ${params}    idPattern=${entity_id_pattern}
    Run Keyword If     '${geoproperty}'!=''       Set To Dictionary   ${params}    geoproperty=${geoproperty}
    ${response}=    POST    ${ENTITY_OPERATIONS_QUERY_ENDPOINT_PATH}    body=${params}    headers=${headers}
    Output  request
    Output  response
    [return]    ${response}

Retrieve Entity by Id
    [Arguments]  ${id}      ${accept}=${CONTENT_TYPE_LD_JSON}     ${context}=${EMPTY}
    ${headers}=  Create Dictionary
    Set To Dictionary   ${headers}   Accept    ${accept}
    Run Keyword If     '${context}'!=''       Set To Dictionary   ${headers}   Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    ${response}=  GET  ${ENTITIES_ENDPOINT_PATH}${id}  headers=${headers}
    Output  request
    Output  response
    Set Test Variable    ${response}

Create Entity Selecting Content Type
    [Arguments]  ${filename}    ${entity_id}    ${content_type}     ${context}=${EMPTY}     ${accept}=${EMPTY}
    ${entity_payload}=    Load Json From File    ${EXECDIR}/data/entities/${filename}
    ${entity}=    Update Value To Json    ${entity_payload}     $..id   ${entity_id}
    &{headers}=  Create Dictionary  Content-Type=${content_type}
    Run Keyword If     '${accept}'!='${EMPTY}'   Set To Dictionary   ${headers}   Accept=${accept}
    Run Keyword If     '${context}'!='${EMPTY}'   Set To Dictionary   ${headers}   Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    ${response}=  POST  ${ENTITIES_ENDPOINT_PATH}  body=${entity}  headers=${headers}
    ${request}=    Output  request
    Output  response
    [return]    ${request}    ${response}

Append Entity Attributes
    [Arguments]  ${id}    ${fragment_filename}    ${content_type}
    &{headers}=  Create Dictionary  Content-Type=${content_type}
    ${fragment_payload}=    Load Json From File    ${EXECDIR}/data/entities/fragmentEntities/${fragment_filename}
    ${response}=  POST  ${ENTITIES_ENDPOINT_PATH}${id}/attrs/  body=${fragment_payload}  headers=${headers}
    Output  request
    Output  response
    [return]   ${response}

Append Entity Attributes With Parameters
    [Arguments]  ${id}    ${fragment_filename}    ${content_type}    ${options}
    &{headers}=  Create Dictionary  Content-Type=${content_type}
    ${fragment_payload}=    Load Json From File    ${EXECDIR}/data/entities/fragmentEntities/${fragment_filename}
    ${response}=  POST  ${ENTITIES_ENDPOINT_PATH}${id}/attrs/?options=${options}  body=${fragment_payload}  headers=${headers}
    Output  request
    Output  response
    [return]   ${response}

Append Entity Attributes Using Session
    [Arguments]  ${id}    ${filename}    ${content_type}    ${options}
    ${file_content}=    Get File    ${EXECDIR}/data/entities/fragmentEntities/${filename}
    Create Session    OneRequest      ${url}
    &{headers}=  Create Dictionary  Content-Type=${content_type}
    ${response}=    POST On Session      OneRequest   ${ENTITIES_ENDPOINT_PATH}${id}/attrs/    params=options=${options}    data=${file_content}    headers=${headers}   expected_status=any
    Set Test Variable  ${response}

Update Entity Attributes Using Session
    [Arguments]  ${id}    ${fragment_filename}    ${content_type}    ${options}
    ${file_content}=    Get File    ${EXECDIR}/data/entities/fragmentEntities/${fragment_filename}
    Create Session    OneRequest      ${url}
    &{headers}=  Create Dictionary  Content-Type=${content_type}
    ${response}=    PATCH On Session      OneRequest   ${ENTITIES_ENDPOINT_PATH}${id}/attrs/    data=${file_content}    headers=${headers}   expected_status=any
    Output  ${response.json()}
    [return]    ${response}

Update Entity Attributes
    [Arguments]  ${id}    ${fragment_filename}    ${content_type}
    &{headers}=  Create Dictionary  Content-Type=${content_type}
    ${fragment_payload}=    Load Json From File    ${EXECDIR}/data/entities/fragmentEntities/${fragment_filename}
    ${response}=  PATCH  ${ENTITIES_ENDPOINT_PATH}${id}/attrs/  body=${fragment_payload}  headers=${headers}
    Output  request
    Output  response
    [return]   ${response}

Delete Entity Attributes
    [Arguments]  ${entityId}     ${attributeId}     ${datasetId}    ${deleteAll}
    ${response}=  DELETE  ${ENTITIES_ENDPOINT_PATH}${entityId}/attrs/${attributeId}?datasetId=${datasetId}&deleteAll=${deleteAll}
    Output  request
    Output  response
    [return]    ${response}

Partial Update Entity Attributes
    [Arguments]  ${entityId}    ${attributeId}    ${fragment_filename}    ${content_type}    ${accept}=${EMPTY}
    &{headers}=  Create Dictionary  Content-Type=${content_type}
    Run Keyword If     '${accept}'!=''       Set To Dictionary   ${headers}   Accept    ${accept}
    ${fragment_payload}=    Load Json From File    ${EXECDIR}/data/entities/fragmentEntities/${fragment_filename}
    ${response}=  PATCH  ${ENTITIES_ENDPOINT_PATH}${entityId}/attrs/${attributeId}  body=${fragment_payload}  headers=${headers}
    Output  request
    Output  response
    [return]   ${response}

Retrieve Entity Types
    [Arguments]  ${context}=${EMPTY}    ${details}=${FALSE}    ${accept}=${EMPTY}

    &{headers}=  Create Dictionary
    &{params}=  Create Dictionary
    Run Keyword If     '${accept}'!=''       Set To Dictionary   ${headers}   Accept    ${accept}
    Run Keyword If     '${context}'!=''       Set To Dictionary   ${headers}    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    Run Keyword If     ${details}       Set To Dictionary   ${params}    details=${details}
    ${response}=  GET  ${ENTITIES_TYPES_ENDPOINT_PATH}/     headers=${headers}   query=${params}
    Output  request
    Output  response

    Set Test Variable  ${response}

Retrieve Entity Type
    [Arguments]  ${type}    ${context}=${EMPTY}    ${accept}=${EMPTY}

    &{headers}=  Create Dictionary
    Run Keyword If     '${accept}'!=''       Set To Dictionary   ${headers}   Accept    ${accept}
    Run Keyword If     '${context}'!=''       Set To Dictionary   ${headers}    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    ${response}=  GET  ${ENTITIES_TYPES_ENDPOINT_PATH}/${type}     headers=${headers}
    Output  request
    Output  response

    Set Test Variable  ${response}

Retrieve Attributes
    [Arguments]  ${context}=${EMPTY}    ${details}=${FALSE}     ${accept}=${EMPTY}

    &{headers}=  Create Dictionary
    &{params}=  Create Dictionary
    Run Keyword If     '${accept}'!=''       Set To Dictionary   ${headers}   Accept    ${accept}
    Run Keyword If     '${context}'!=''       Set To Dictionary   ${headers}    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    Run Keyword If     ${details}       Set To Dictionary   ${params}    details=${details}
    ${response}=  GET  ${ATTRIBUTES_ENDPOINT_PATH}     headers=${headers}   query=${params}
    Output  request
    Output  response

    Set Test Variable  ${response}

Retrieve Attribute
    [Arguments]  ${attribute_name}      ${context}=${EMPTY}     ${accept}=${EMPTY}

    &{headers}=  Create Dictionary
    Run Keyword If     '${accept}'!=''       Set To Dictionary   ${headers}   Accept    ${accept}
    Run Keyword If     '${context}'!=''       Set To Dictionary   ${headers}    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    ${response}=  GET  ${ATTRIBUTES_ENDPOINT_PATH}/${attribute_name}     headers=${headers}
    Output  request
    Output  response

    Set Test Variable  ${response}

Create Context Source Registration With Return
    [Arguments]  ${payload}      ${content_type}=${CONTENT_TYPE_LD_JSON}     ${context}=${EMPTY}     ${accept}=${EMPTY}
    &{headers}=  Create Dictionary  Content-Type=${content_type}
    Run Keyword If     '${accept}'!=''       Set To Dictionary   ${headers}   Accept=${context}
    Run Keyword If     '${context}'!=''       Set To Dictionary   ${headers}   Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    ${response}=  POST  ${CONTEXT_SOURCE_REGISTRATION_ENDPOINT_PATH}  body=${payload}  headers=${headers}
    ${request}=    Output  request
    Output  response
    [return]    ${request}    ${response}

Create Context Source Registration Using Session
    [Arguments]  ${filename}    ${content_type}
    ${file_content}=    Get File    ${EXECDIR}/data/csourceRegistrations/${filename}
    Create Session    OneRequest      ${url}
    &{headers}=  Create Dictionary  Content-Type=${content_type}
    ${response}=    POST On Session      OneRequest   ${CONTEXT_SOURCE_REGISTRATION_ENDPOINT_PATH}    data=${file_content}    headers=${headers}   expected_status=any
    Output  ${response.json()}
    [return]    ${response}

Update Context Source Registration With Return
    [Arguments]  ${registration_id}    ${fragment}    ${content_type}     ${accept}=${EMPTY}
    &{headers}=  Create Dictionary  Content-Type=${content_type}
     Run Keyword If     '${accept}'!=''       Set To Dictionary   ${headers}   Accept=${accept}
    ${response}=  PATCH  ${CONTEXT_SOURCE_REGISTRATION_ENDPOINT_PATH}/${registration_id}  body=${fragment}  headers=${headers}
    ${request}=    Output  request
    Output  response
    [return]    ${response}

Update Context Source Registration Using Session
    [Arguments]  ${registration_id}    ${filename}    ${content_type}
     ${file_content}=    Get File    ${EXECDIR}/data/csourceRegistrations/${filename}
    Create Session    OneRequest      ${url}
    &{headers}=  Create Dictionary  Content-Type=${content_type}
    ${response}=    PATCH On Session      OneRequest   ${CONTEXT_SOURCE_REGISTRATION_ENDPOINT_PATH}/${registration_id}    data=${file_content}    headers=${headers}   expected_status=any
    Output  request
    Output  response
    [return]    ${response}

Delete Context Source Registration With Return
    [Arguments]  ${registration_id}
    ${response}=  DELETE  ${CONTEXT_SOURCE_REGISTRATION_ENDPOINT_PATH}/${registration_id}
    Output  request
    Output  response
    [return]  ${response}

Create Entity
    [Arguments]  ${filename}    ${entity_id}
    ${entity_payload}=    Load Json From File    ${EXECDIR}/data/entities/${filename}
    ${entity}=    Update Value To Json    ${entity_payload}     $..id   ${entity_id}
    &{headers}=  Create Dictionary  Content-Type=application/ld+json
    ${response}=  POST  ${ENTITIES_ENDPOINT_PATH}  body=${entity}  headers=${headers}
    Output  request
    Output  response

Create Or Update Temporal Representation Of Entity Selecting Content Type
    [Arguments]  ${temporal_entity_representation_id}    ${filename}    ${content_type}    ${accept}=${EMPTY}
    ${temporal_entity_representation_payload}=    Load Json From File    ${EXECDIR}/data/temporalEntities/${filename}
    ${temporal_entity_representation}=    Update Value To Json    ${temporal_entity_representation_payload}     $..id   ${temporal_entity_representation_id}
    &{headers}=  Create Dictionary  Content-Type=${content_type}
    Run Keyword If     '${accept}'!=''       Set To Dictionary   ${headers}   Accept    ${accept}
    ${response}=  POST  ${TEMPORAL_ENTITIES_ENDPOINT_PATH}/  body=${temporal_entity_representation}  headers=${headers}
    Output  request
    Output  response
    [return]  ${response}

Create Temporal Representation Of Entity Selecting Content Type Using Session
    [Arguments]  ${filename}    ${content_type}
    ${file_content}=    Get File    ${EXECDIR}/data/temporalEntities/${filename}
    Create Session    OneRequest      ${url}
    &{headers}=  Create Dictionary  Content-Type=${content_type}
    ${response}=  POST On Session      OneRequest   ${TEMPORAL_ENTITIES_ENDPOINT_PATH}    data=${file_content}    headers=${headers}
    Output  request
    Output  response
    [return]    ${response}

Append Attribute To Temporal Entity
    [Arguments]  ${temporal_entity_id}    ${fragment_filename}    ${content_type}
    &{headers}=  Create Dictionary  Content-Type=${content_type}
    ${fragment_payload}=    Load Json From File    ${EXECDIR}/data/temporalEntities/fragments/${fragment_filename}
    ${response}=  POST  ${TEMPORAL_ENTITIES_ENDPOINT_PATH}/${temporal_entity_id}/attrs  body=${fragment_payload}  headers=${headers}
    Output  request
    Output  response
    [return]   ${response}

Append Attribute To Temporal Entity Using Session
    [Arguments]  ${temporal_entity_id}    ${fragment_filename}    ${content_type}
    &{headers}=  Create Dictionary  Content-Type=${content_type}
    ${file_content}=    Get File    ${EXECDIR}/data/temporalEntities/fragments/${fragment_filename}
    Create Session    OneRequest      ${url}
    ${response}=  POST On Session      OneRequest   ${TEMPORAL_ENTITIES_ENDPOINT_PATH}/${temporal_entity_id}/attrs  data=${file_content}  headers=${headers}
    Output  request
    Output  response
    [return]   ${response}

Partial Update Attribute From Temporal Entity
    [Arguments]  ${temporal_entity_id}    ${attributeId}    ${instanceId}    ${fragment_filename}    ${content_type}
    &{headers}=  Create Dictionary  Content-Type=${content_type}
    ${fragment_payload}=    Load Json From File    ${EXECDIR}/data/temporalEntities/fragments/${fragment_filename}
    ${response}=  PATCH  ${TEMPORAL_ENTITIES_ENDPOINT_PATH}/${temporal_entity_id}/attrs/${attributeId}/${instanceId}  body=${fragment_payload}  headers=${headers}
    Output  request
    Output  response
    [return]   ${response}

Delete Attribute From Temporal Entity
    [Arguments]  ${entityId}    ${attributeId}    ${content_type}    ${datasetId}     ${deleteAll}
    &{headers}=  Create Dictionary  Content-Type=${content_type}
    ${response}=  DELETE  ${TEMPORAL_ENTITIES_ENDPOINT_PATH}/${entityId}/attrs/${attributeId}?datasetId=${datasetId}&deleteAll=${deleteAll}  headers=${headers}
    Output  request
    Output  response
    [return]   ${response}

Delete Temporal Representation Of Entity With Returning Response
    [Arguments]  ${temporal_entity_representation_id}
    ${response}=  DELETE  ${TEMPORAL_ENTITIES_ENDPOINT_PATH}/${temporal_entity_representation_id}
    Output  request
    Output  response
    [return]   ${response}

Delete Several Temporal Representations Of Entities
    [Arguments]  @{temporal_entity_representation_ids}
    FOR    ${temporal_entity_representation_id}    IN    @{temporal_entity_representation_ids}
        Delete Temporal Representation Of Entity With Returning Response  ${temporal_entity_representation_id}
    END

Get Temporal Representation Of Entity
    [Arguments]  ${temporal_entity_representation_id}    ${accept}=${EMPTY}    ${options}=${EMPTY}
    &{headers}=  Create Dictionary
    &{params}=  Create Dictionary
    ${options_length} =  Get Length  ${options}
    Run Keyword If     '${accept}'!=''       Set To Dictionary   ${headers}   Accept    ${accept}
    Run Keyword If     ${options_length}>0       Set To Dictionary   ${params}       options=${options}
    ${response}=  GET  ${TEMPORAL_ENTITIES_ENDPOINT_PATH}/${temporal_entity_representation_id}      headers=${headers}    query=${params}
    Output  request
    Output  response
    [return]  ${response}

Delete Attribute Instance From Temporal Entity
    [Arguments]  ${temporal_entity_id}    ${attributeId}    ${instanceId}    ${content_type}
    ${response}=  DELETE  ${TEMPORAL_ENTITIES_ENDPOINT_PATH}/${temporal_entity_id}/attrs/${attributeId}/${instanceId}
    Output  request
    Output  response
    [return]  ${response}

Update Temporal Representation Of Entity Selecting Content Type
    [Arguments]   ${temporal_entity_representation_id}    ${attrId}    ${instanceId}    ${fragment_filename}    ${content_type}
    ${temporal_entity_fragment}=    Load Json From File    ${EXECDIR}/data/temporalEntities/fragments/${fragment_filename}
    &{headers}=  Create Dictionary  Content-Type=${content_type}
    ${response}=  PATCH  ${TEMPORAL_ENTITIES_ENDPOINT_PATH}/${temporal_entity_representation_id}/attrs/${attrId}/${instanceId}  body=${temporal_entity_fragment}  headers=${headers}
    Output  request
    Output  response
    [return]  ${response}

Batch Create Entities
    [Arguments]  @{entities_to_be_created}      ${content_type}=${CONTENT_TYPE_LD_JSON}     ${context}=${EMPTY}     ${accept}=${EMPTY}
    ${headers}=  Create Dictionary
    Set To Dictionary   ${headers}   Content-Type    ${content_type}
    Run Keyword If     '${accept}'!=''       Set To Dictionary   ${headers}   Accept    ${accept}
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

Request Entity From File
    [Arguments]  ${filename}
    ${file_content}=    Get File    ${EXECDIR}/data/entities/${filename}
    Create Session    OneRequest      ${url}
    &{headers}=  Create Dictionary  Content-Type=application/ld+json
    ${response}=  POST On Session      OneRequest   ${ENTITIES_ENDPOINT_PATH}  data=${file_content}    headers=${headers}   expected_status=any
    Set Test Variable  ${response}

Batch Request Entities From File
    [Arguments]  ${batchOperation}      ${filename}
    ${file_content}=    Get File    ${EXECDIR}/data/entities/${filename}
    ${endpoint_url}=    Get From Dictionary     ${BATCH_OPERATION_ENDPOINT_MAPPING}     ${batchOperation}
    Create Session    BatchRequest      ${url}
    &{headers}=  Create Dictionary  Content-Type=application/ld+json
    ${response}=  POST On Session      BatchRequest   ${endpoint_url}  data=${file_content}    headers=${headers}   expected_status=any
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
    [Arguments]  ${temporal_entity_representation_id}   ${attrs}=${EMPTY}      ${options}=${EMPTY}      ${context}=${EMPTY}     ${timerel}=${EMPTY}      ${timeAt}=${EMPTY}    ${endTimeAt}=${EMPTY}    ${lastN}=${EMPTY}    ${accept}=${EMPTY}
    ${attrs_length} =  Get Length  ${attrs}
    ${options_length} =  Get Length  ${options}
    &{headers}=  Create Dictionary
    &{params}=  Create Dictionary

    Run Keyword If     '${accept}'!=''       Set To Dictionary   ${headers}    Accept=${accept}
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
    [Arguments]  ${context}=${EMPTY}     ${entity_types}=${EMPTY}   ${entity_ids}=${EMPTY}    ${entity_id_pattern}=${EMPTY}    ${ngsild_query}=${EMPTY}  ${csf}=${EMPTY}   ${georel}=${EMPTY}   ${geometry}=${EMPTY}    ${coordinates}=${EMPTY}    ${geoproperty}=${EMPTY}    ${timerel}=${EMPTY}      ${timeAt}=${EMPTY}     ${attrs}=${EMPTY}   ${limit}=${EMPTY}   ${lastN}=${EMPTY}    ${accept}=${EMPTY}
    ${entity_types_length} =  Get Length  ${entity_types}
    ${entity_ids_length} =  Get Length  ${entity_ids}
    ${attrs_length} =  Get Length  ${attrs}
    &{headers}=  Create Dictionary
    &{params}=  Create Dictionary
    Run Keyword If     '${accept}'!=''       Set To Dictionary   ${headers}    Accept=${accept}
    Run Keyword If     '${context}'!=''       Set To Dictionary   ${headers}    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    Run Keyword If     ${entity_types_length}>0       Set To Dictionary   ${params}    type=${entity_types}
    Run Keyword If     ${entity_ids_length}>0       Set To Dictionary   ${params}    id=${entity_ids}
    Run Keyword If     '${timerel}'!=''       Set To Dictionary   ${params}    timerel=${timerel}
    Run Keyword If     '${timeAt}'!=''       Set To Dictionary   ${params}    timeAt=${timeAt}
    Run Keyword If     ${attrs_length}>0       Set To Dictionary   ${params}       attrs=${attrs}
    Run Keyword If     '${lastN}'!=''       Set To Dictionary   ${params}    lastN=${lastN}
    Run Keyword If     '${entity_id_pattern}'!=''       Set To Dictionary   ${params}    idPattern=${entity_id_pattern}
    Run Keyword If     '${ngsild_query}'!=''       Set To Dictionary   ${params}    q=${ngsild_query}
    Run Keyword If     '${csf}'!=''       Set To Dictionary   ${params}    csf=${csf}
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
    [Arguments]  ${query_file_name}    ${content_type}=${CONTENT_TYPE_LD_JSON}
    ${headers}=  Create Dictionary
    Set To Dictionary   ${headers}   Content-Type    ${content_type}
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

Create Context Source Registration
    [Arguments]  ${context_source_registration_payload}

    &{headers}=  Create Dictionary  Content-Type=application/ld+json
    ${response}=  POST  ${CONTEXT_SOURCE_REGISTRATION_ENDPOINT_PATH}  body=${context_source_registration_payload}  headers=${headers}
    ${request}=    Output  request
    Output  response

    Set Suite Variable  ${request}
    Set Suite Variable  ${response}

Update Context Source Registration
    [Arguments]  ${context_source_registration_id}     ${update_fragment}

    ${response}=  PATCH  ${CONTEXT_SOURCE_REGISTRATION_ENDPOINT_PATH}/${context_source_registration_id}    body=${update_fragment}
    Output  request
    Output  response

    Set Test Variable  ${response}

Query Context Source Registrations
    [Arguments]     ${context}=${EMPTY}     ${id}=${EMPTY}  ${type}=${EMPTY}    ${attrs}=${EMPTY}   ${q}=${EMPTY}   ${csf}=${EMPTY}   ${georel}=${EMPTY}  ${geometry}=${EMPTY}  ${coordinates}=${EMPTY}  ${geoproperty}=${EMPTY}  ${timeproperty}=${EMPTY}     ${timerel}=${EMPTY}     ${timeAt}=${EMPTY}     ${limit}=${EMPTY}   ${page}=${EMPTY}

    &{headers}=  Create Dictionary
    &{params}=  Create Dictionary
    Run Keyword If     '${context}'!=''       Set To Dictionary   ${headers}    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    Run Keyword If     '${accept}'!=''       Set To Dictionary   ${headers}    accept=${accept}
    Run Keyword If     '${id}'!=''       Set To Dictionary   ${params}    id=${id}
    Run Keyword If     '${type}'!=''       Set To Dictionary   ${params}    type=${type}
    Run Keyword If     '${attrs}'!=''       Set To Dictionary   ${params}    attrs=${attrs}
    Run Keyword If     '${q}'!=''       Set To Dictionary   ${params}    q=${q}
    Run Keyword If     '${csf}'!=''       Set To Dictionary   ${params}    csf=${csf}
    Run Keyword If     '${georel}'!=''       Set To Dictionary   ${params}    georel=${georel}
    Run Keyword If     '${geometry}'!=''       Set To Dictionary   ${params}    geometry=${geometry}
    Run Keyword If     '${coordinates}'!=''       Set To Dictionary   ${params}    coordinates=${coordinates}
    Run Keyword If     '${geoproperty}'!=''       Set To Dictionary   ${params}    geoproperty=${geoproperty}
    Run Keyword If     '${timeproperty}'!=''       Set To Dictionary   ${params}    timeproperty=${timeproperty}
    Run Keyword If     '${timerel}'!=''       Set To Dictionary   ${params}    timerel=${timerel}
    Run Keyword If     '${timeAt}'!=''       Set To Dictionary   ${params}    timeAt=${timeAt}
    Run Keyword If     '${limit}'!=''       Set To Dictionary   ${params}    limit=${limit}
    Run Keyword If     '${page}'!=''       Set To Dictionary   ${params}    page=${page}

    ${response}=  GET  ${CONTEXT_SOURCE_REGISTRATION_ENDPOINT_PATH}     headers=${headers}     query=${params}
    Output  request
    Output  response

    Set Test Variable  ${response}

Delete Context Source Registration
    [Arguments]  ${context_source_registration_id}

    ${response}=  DELETE  ${CONTEXT_SOURCE_REGISTRATION_ENDPOINT_PATH}/${context_source_registration_id}
    Output  request
    Output  response

    Set Suite Variable  ${response}

Retrieve Context Source Registration
    [Arguments]  ${context_source_registration_id}     ${context}=${EMPTY}    ${accept}=${EMPTY}

    &{headers}=  Create Dictionary
    Run Keyword If     '${accept}'!=''       Set To Dictionary   ${headers}    Accept=${accept}
    Run Keyword If     '${context}'!=''       Set To Dictionary   ${headers}    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    ${response}=  GET  ${CONTEXT_SOURCE_REGISTRATION_ENDPOINT_PATH}/${context_source_registration_id}     headers=${headers}
    Output  request
    Output  response

    Set Test Variable  ${response}

Create Context Source Registration Subscription
    [Arguments]  ${subscription_payload}    ${accept}=${EMPTY}    ${content_type}=${CONTENT_TYPE_LD_JSON}

    &{headers}=  Create Dictionary  Content-Type=${content_type}
    Run Keyword If     '${accept}'!=''       Set To Dictionary   ${headers}   Accept    ${accept}
    ${response}=  POST  ${CONTEXT_SOURCE_REGISTRATION_SUBSCRIPTION_ENDPOINT_PATH}  body=${subscription_payload}  headers=${headers}
    ${request}=    Output  request
    Output  response

    Set Suite Variable  ${request}
    Set Suite Variable  ${response}

Update Context Source Registration Subscription
    [Arguments]  ${subscription_id}     ${subscription_update_fragment}

    ${response}=  PATCH  ${CONTEXT_SOURCE_REGISTRATION_SUBSCRIPTION_ENDPOINT_PATH}/${subscription_id}    body=${subscription_update_fragment}
    Output  request
    Output  response

    Set Test Variable  ${response}

Retrieve Context Source Registration Subscription
    [Arguments]  ${subscription_id}     ${context}=${EMPTY}     ${accept}=${CONTENT_TYPE_JSON}

    &{headers}=  Create Dictionary
    Set To Dictionary   ${headers}   Accept    ${accept}
    Run Keyword If     '${context}'!=''       Set To Dictionary   ${headers}    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    ${response}=  GET  ${CONTEXT_SOURCE_REGISTRATION_SUBSCRIPTION_ENDPOINT_PATH}/${subscription_id}     headers=${headers}
    Output  request
    Output  response

    Set Test Variable  ${response}

Query Context Source Registration Subscriptions
    [Arguments]  ${context}=${EMPTY}    ${limit}=${EMPTY}   ${page}=${EMPTY}    ${accept}=${EMPTY}

    &{headers}=  Create Dictionary
    &{params}=  Create Dictionary
    Run Keyword If     '${accept}'!=''       Set To Dictionary   ${headers}    Accept=${accept}
    Run Keyword If     '${context}'!=''       Set To Dictionary   ${headers}    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    Run Keyword If     '${limit}'!=''       Set To Dictionary   ${params}    limit=${limit}
    Run Keyword If     '${page}'!=''       Set To Dictionary   ${params}    page=${page}

    ${response}=  GET  ${CONTEXT_SOURCE_REGISTRATION_SUBSCRIPTION_ENDPOINT_PATH}     headers=${headers}     query=${params}
    Output  request
    Output  response

    Set Test Variable  ${response}

Delete Context Source Registration Subscription
    [Arguments]  ${subscription_id}

    ${response}=  DELETE  ${CONTEXT_SOURCE_REGISTRATION_SUBSCRIPTION_ENDPOINT_PATH}/${subscription_id}
    Output  request
    Output  response

    Set Suite Variable  ${response}

Update Context Source Registration Subscription From File
    [Arguments]  ${subscription_id}      ${file_path}
    ${file_content}=    Get File    ${EXECDIR}/data/${file_path}
    Create Session    CsrsUpdateRequest      ${url}
    ${response}=  PATCH On Session      CsrsUpdateRequest   ${CONTEXT_SOURCE_REGISTRATION_SUBSCRIPTION_ENDPOINT_PATH}/${subscription_id}  data=${file_content}   expected_status=any
    Set Test Variable  ${response}

Create Subscription
    [Arguments]  ${subscription_id}    ${filename_path}    ${content_type}    ${accept}=${EMPTY}    ${context}=${EMPTY}
    &{headers}=  Create Dictionary  Content-Type=${content_type}
    Run Keyword If     '${accept}'!=''       Set To Dictionary   ${headers}   Accept    ${accept}
    Run Keyword If     '${context}'!=''       Set To Dictionary   ${headers}    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    ${subscription_payload}=    Load Json From File    ${EXECDIR}/data/${filename_path}
    ${subscription}=    Update Value To Json    ${subscription_payload}     $..id   ${subscription_id}
    ${response}=  POST  ${SUBSCRIPTION_ENDPOINT_PATH}  body=${subscription}  headers=${headers}
    Output  request
    Output  response
    [return]   ${response}

Update Subscription
    [Arguments]  ${subscription_id}     ${fragment_filename}    ${content_type}    ${accept}=${EMPTY}   ${context}=${EMPTY}
    &{headers}=  Create Dictionary  Content-Type=${content_type}
    Run Keyword If     '${accept}'!=''       Set To Dictionary   ${headers}   Accept    ${accept}
    Run Keyword If     '${context}'!=''       Set To Dictionary   ${headers}    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    ${subscription_update_fragment}=    Load Json From File    ${EXECDIR}/data/${fragment_filename}
    ${response}=  PATCH  ${SUBSCRIPTION_ENDPOINT_PATH}${subscription_id}    body=${subscription_update_fragment}     headers=${headers}
    Output  request
    Output  response
    Set Test Variable  ${response}
    [return]   ${response}

Delete Subscription
    [Arguments]  ${subscription_id}
    ${response}=  DELETE  ${SUBSCRIPTION_ENDPOINT_PATH}${subscription_id}
    Output  request
    Output  response
    Set Suite Variable  ${response}
    [return]   ${response}

Query Subscriptions
    [Arguments]  ${context}=${EMPTY}    ${limit}=${EMPTY}   ${page}=${EMPTY}    ${accept}=${EMPTY}

    &{headers}=  Create Dictionary
    &{params}=  Create Dictionary
    Run Keyword If     '${context}'!=''       Set To Dictionary   ${headers}    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    Run Keyword If     '${limit}'!=''       Set To Dictionary   ${params}    limit=${limit}
    Run Keyword If     '${page}'!=''       Set To Dictionary   ${params}    page=${page}
    Run Keyword If     '${accept}'!=''       Set To Dictionary   ${headers}   Accept    ${accept}

    ${response}=  GET  ${SUBSCRIPTION_ENDPOINT_PATH}     headers=${headers}     query=${params}
    Output  request
    Output  response

    Set Test Variable  ${response}

Retrieve Subscription
    [Arguments]  ${id}   ${accept}=${EMPTY}     ${context}=${EMPTY}
    &{headers}=  Create Dictionary

    Run Keyword If     '${accept}'!=''       Set To Dictionary   ${headers}   Accept    ${accept}
    Run Keyword If     '${context}'!=''       Set To Dictionary   ${headers}    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"

    ${response}=  GET  ${SUBSCRIPTION_ENDPOINT_PATH}${id}      headers=${headers}
    ${request}=  Output  request
    Output  response
    Set Test Variable  ${response}
    [return]    ${request}    ${response}

Update Context Source Registration Subscription By Selecting Content Type
    [Arguments]  ${subscription_id}     ${subscription_update_fragment}    ${content_type}    ${accept}=${EMPTY}
    &{headers}=  Create Dictionary  Content-Type=${content_type}
    Run Keyword If     '${accept}'!=''       Set To Dictionary   ${headers}   Accept    ${accept}
    ${response}=  PATCH  ${CONTEXT_SOURCE_REGISTRATION_SUBSCRIPTION_ENDPOINT_PATH}/${subscription_id}    body=${subscription_update_fragment}    headers=${headers}
    Output  request
    Output  response
    [return]   ${response}

Retrieve Entity Types With Return
    [Arguments]  ${accept}=${EMPTY}   
    &{headers}=  Create Dictionary
    Run Keyword If     '${accept}'!=''       Set To Dictionary   ${headers}   Accept    ${accept}
    ${response}=  GET  ${ENTITIES_TYPES_ENDPOINT_PATH}      headers=${headers}
    Output  request
    Output  response
    [return]    ${response}

Retrieve Entity Type With Return
    [Arguments]  ${type}    ${accept}=${EMPTY} 
    &{headers}=  Create Dictionary
    Run Keyword If     '${accept}'!=''       Set To Dictionary   ${headers}   Accept    ${accept}
    ${response}=  GET  ${ENTITIES_TYPES_ENDPOINT_PATH}/${type}      headers=${headers}
    Output  request
    Output  response
    [return]    ${response}

Retrieve Attributes With Return
    [Arguments]  ${accept}=${EMPTY} 
    &{headers}=  Create Dictionary
    Run Keyword If     '${accept}'!=''       Set To Dictionary   ${headers}   Accept    ${accept}
    ${response}=  GET  ${ATTRIBUTES_ENDPOINT_PATH}     headers=${headers}
    Output  request
    Output  response
    [return]    ${response}

Retrieve Attribute With Return
    [Arguments]  ${attribute_name}    ${accept}=${EMPTY} 
    &{headers}=  Create Dictionary
    Run Keyword If     '${accept}'!=''       Set To Dictionary   ${headers}   Accept    ${accept}
    ${response}=  GET  ${ATTRIBUTES_ENDPOINT_PATH}/${attribute_name}     headers=${headers}
    Output  request
    Output  response
    [return]    ${response}

Create Context Source Registration Subscription With Return
    [Arguments]  ${subscription_payload}    ${content_type}
    &{headers}=  Create Dictionary  Content-Type=${content_type}
    ${response}=  POST  ${CONTEXT_SOURCE_REGISTRATION_SUBSCRIPTION_ENDPOINT_PATH}  body=${subscription_payload}  headers=${headers}
    ${request}=    Output  request
    Output  ${response}
    [return]    ${request}    ${response}

Batch Upsert Entities By Selecting Content Type
    [Arguments]  @{entities_to_be_upserted}    ${content_type}=${CONTENT_TYPE_LD_JSON}     ${update_option}=replace
    &{headers}=  Create Dictionary  Content-Type=${content_type}
    ${response}=  POST  ${BATCH_UPSERT_ENDPOINT_PATH}?options=${update_option}  body=@{entities_to_be_upserted}  headers=${headers}
    Output  request
    Output  response
    Set Test Variable  ${response}

Batch Update Entities By Selecting Content Type
    [Arguments]  @{entities_to_be_updated}    ${content_type}=${CONTENT_TYPE_LD_JSON}     ${overwrite_option}=overwrite
    &{headers}=  Create Dictionary  Content-Type=${content_type}
    ${response}=  POST  ${BATCH_UPDATE_ENDPOINT_PATH}?options=${overwrite_option}  body=@{entities_to_be_updated}  headers=${headers}
    Output  request
    Output  response
    Set Test Variable  ${response}

Batch Delete Entities By Selecting Content Type
    [Arguments]  @{entities_ids_to_be_deleted}    ${content_type}=${CONTENT_TYPE_LD_JSON}    ${teardown}=False
    &{headers}=  Create Dictionary  Content-Type=${content_type}
    ${response}=  POST  ${BATCH_DELETE_ENDPOINT_PATH}  body=@{entities_ids_to_be_deleted}  headers=${headers}
    Output  request
    Output  response
    Run Keyword If     not ${teardown}       Set Test Variable  ${response}
    Set Test Variable  ${response}

Query Context Source Registrations With Return
    [Arguments]     ${context}=${EMPTY}     ${id}=${EMPTY}  ${type}=${EMPTY}    ${attrs}=${EMPTY}   ${q}=${EMPTY}   ${georel}=${EMPTY}  ${geometry}=${EMPTY}  ${coordinates}=${EMPTY}  ${geoproperty}=${EMPTY}  ${timeproperty}=${EMPTY}     ${timerel}=${EMPTY}     ${timeAt}=${EMPTY}     ${limit}=${EMPTY}   ${page}=${EMPTY}   ${accept}=${EMPTY}

    &{headers}=  Create Dictionary
    &{params}=  Create Dictionary
    Run Keyword If     '${context}'!=''       Set To Dictionary   ${headers}    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    Run Keyword If     '${accept}'!=''       Set To Dictionary   ${headers}    accept=${accept}
    Run Keyword If     '${id}'!=''       Set To Dictionary   ${params}    id=${id}
    Run Keyword If     '${type}'!=''       Set To Dictionary   ${params}    type=${type}
    Run Keyword If     '${attrs}'!=''       Set To Dictionary   ${params}    attrs=${attrs}
    Run Keyword If     '${q}'!=''       Set To Dictionary   ${params}    q=${q}
    Run Keyword If     '${georel}'!=''       Set To Dictionary   ${params}    georel=${georel}
    Run Keyword If     '${geometry}'!=''       Set To Dictionary   ${params}    geometry=${geometry}
    Run Keyword If     '${coordinates}'!=''       Set To Dictionary   ${params}    coordinates=${coordinates}
    Run Keyword If     '${geoproperty}'!=''       Set To Dictionary   ${params}    geoproperty=${geoproperty}
    Run Keyword If     '${timeproperty}'!=''       Set To Dictionary   ${params}    timeproperty=${timeproperty}
    Run Keyword If     '${timerel}'!=''       Set To Dictionary   ${params}    timerel=${timerel}
    Run Keyword If     '${timeAt}'!=''       Set To Dictionary   ${params}    timeAt=${timeAt}
    Run Keyword If     '${limit}'!=''       Set To Dictionary   ${params}    limit=${limit}
    Run Keyword If     '${page}'!=''       Set To Dictionary   ${params}    page=${page}

    ${response}=  GET  ${CONTEXT_SOURCE_REGISTRATION_ENDPOINT_PATH}     headers=${headers}     query=${params}
    ${request}=  Output  request
    Output  response

    [return]  ${request}    ${response}

Query Temporal Representation Of Entities With Return
    [Arguments]  ${context}=${EMPTY}     ${entity_types}=${EMPTY}   ${entity_ids}=${EMPTY}    ${entity_id_pattern}=${EMPTY}    ${ngsild_query}=${EMPTY}  ${csf}=${EMPTY}   ${georel}=${EMPTY}   ${geometry}=${EMPTY}    ${coordinates}=${EMPTY}    ${geoproperty}=${EMPTY}    ${timerel}=${EMPTY}      ${timeAt}=${EMPTY}     ${attrs}=${EMPTY}   ${limit}=${EMPTY}   ${lastN}=${EMPTY}    ${accept}=${EMPTY}
    ${entity_types_length} =  Get Length  ${entity_types}
    ${entity_ids_length} =  Get Length  ${entity_ids}
    ${attrs_length} =  Get Length  ${attrs}
    &{headers}=  Create Dictionary
    &{params}=  Create Dictionary
    Run Keyword If     '${accept}'!=''       Set To Dictionary   ${headers}    Accept=${accept}
    Run Keyword If     '${context}'!=''       Set To Dictionary   ${headers}    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    Run Keyword If     ${entity_types_length}>0       Set To Dictionary   ${params}    type=${entity_types}
    Run Keyword If     ${entity_ids_length}>0       Set To Dictionary   ${params}    id=${entity_ids}
    Run Keyword If     '${timerel}'!=''       Set To Dictionary   ${params}    timerel=${timerel}
    Run Keyword If     '${timeAt}'!=''       Set To Dictionary   ${params}    timeAt=${timeAt}
    Run Keyword If     ${attrs_length}>0       Set To Dictionary   ${params}       attrs=${attrs}
    Run Keyword If     '${lastN}'!=''       Set To Dictionary   ${params}    lastN=${lastN}
    Run Keyword If     '${entity_id_pattern}'!=''       Set To Dictionary   ${params}    idPattern=${entity_id_pattern}
    Run Keyword If     '${ngsild_query}'!=''       Set To Dictionary   ${params}    q=${ngsild_query}
    Run Keyword If     '${csf}'!=''       Set To Dictionary   ${params}    csf=${csf}
    Run Keyword If     '${georel}'!=''       Set To Dictionary   ${params}    georel=${georel}
    Run Keyword If     '${geometry}'!=''       Set To Dictionary   ${params}    geometry=${geometry}
    Run Keyword If     '${coordinates}'!=''       Set To Dictionary   ${params}    coordinates=${coordinates}
    Run Keyword If     '${geoproperty}'!=''       Set To Dictionary   ${params}    geoproperty=${geoproperty}
    Run Keyword If     '${limit}'!=''       Set To Dictionary   ${params}    limit=${limit}

    ${response}=  GET  ${TEMPORAL_ENTITIES_ENDPOINT_PATH}      headers=${headers}      query=${params}
    ${request}=  Output  request
    Output  response
    [return]  ${request}    ${response}
