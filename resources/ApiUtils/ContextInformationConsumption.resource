*** Settings ***
Variables       ${EXECDIR}/resources/variables.py
Library         ${EXECDIR}/libraries/logUtils.py
Library         Collections
Library         OperatingSystem
Library         RequestsLibrary


*** Variables ***
${ATTRIBUTES_ENDPOINT_PATH}                 attributes
${ENTITIES_ENDPOINT_PATH}                   entities/
${ENTITY_OPERATIONS_QUERY_ENDPOINT_PATH}    entityOperations/query
${ENTITIES_TYPES_ENDPOINT_PATH}             types

${CONTENT_TYPE_JSON}                        application/json
${CONTENT_TYPE_LD_JSON}                     application/ld+json
${CONTENT_TYPE_GEOJSON}                     application/geo+json

${ERROR_TYPE_BAD_REQUEST_DATA}              https://uri.etsi.org/ngsi-ld/errors/BadRequestData
${ERROR_TYPE_INVALID_REQUEST}               https://uri.etsi.org/ngsi-ld/errors/InvalidRequest
${ERROR_TYPE_RESOURCE_NOT_FOUND}            https://uri.etsi.org/ngsi-ld/errors/ResourceNotFound

${response}                                 ${EMPTY}


*** Keywords ***
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
    ...    ${scopeq}=${EMPTY}
    ...    ${georel}=${EMPTY}
    ...    ${coordinates}=${EMPTY}
    ...    ${geometry}=${EMPTY}
    ...    ${count}=${EMPTY}
    ...    ${q}=${EMPTY}
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
    IF    '${scopeq}'!=''    Set To Dictionary    ${params}    scopeQ=${scopeq}
    IF    '${georel}'!=''    Set To Dictionary    ${params}    georel=${georel}
    IF    '${coordinates}'!=''
        Set To Dictionary    ${params}    coordinates=${coordinates}
    END
    IF    '${geometry}'!=''
        Set To Dictionary    ${params}    geometry=${geometry}
    END
    IF    '${count}'!=''    Set To Dictionary    ${params}    count=${count}
    IF    '${q}'!=''    Set To Dictionary    ${params}    q=${q}

    ${response}=    GET
    ...    url=${url}/${ENTITIES_ENDPOINT_PATH}
    ...    headers=${headers}
    ...    params=${params}
    ...    expected_status=any
    Output    ${response}    Query Entities
    RETURN    ${response}

Query Entities Via POST
    [Arguments]
    ...    ${entities}=${EMPTY}
    ...    ${content_type}=${CONTENT_TYPE_JSON}
    ...    ${accept}=${CONTENT_TYPE_JSON}
    ...    ${context}=${EMPTY}
    ...    ${attrs}=${EMPTY}
    ...    ${geometry_property}=${EMPTY}
    &{headers}=    Create Dictionary
    Set To Dictionary    ${headers}    Content-Type    ${content_type}
    Set To Dictionary    ${headers}    Accept    ${accept}
    IF    '${context}'!=''
        Set To Dictionary
        ...    ${headers}
        ...    Link=<${context}>; rel="http://www.w3.org/ns/json-ld#context";type="application/ld+json"
    END
    &{body}=    Create Dictionary
    Set To Dictionary    ${body}    type=Query
    ${entities_length}=    Get Length    ${entities}
    IF    ${entities_length}>0
        Set To Dictionary    ${body}    entities=${entities}
    END
    ${attrs_length}=    Get Length    ${attrs}
    IF    ${attrs_length}>0    Set To Dictionary    ${body}    attrs=${attrs}
    IF    '${geometry_property}'!=''
        Set To Dictionary    ${body}    geometryProperty=${geometry_property}
    END
    ${response}=    POST
    ...    url=${url}/${ENTITY_OPERATIONS_QUERY_ENDPOINT_PATH}
    ...    json=${body}
    ...    headers=${headers}
    ...    expected_status=any
    Output    ${response}    Query Entities Via POST
    RETURN    ${response}

Query Entity
    [Arguments]
    ...    ${id}
    ...    ${accept}=${EMPTY}
    ...    ${attrs}=${EMPTY}
    ...    ${context}=${EMPTY}
    ...    ${geoproperty}=${EMPTY}
    ...    ${options}=${EMPTY}
    ...    ${lang}=${EMPTY}
    ${attrs_length}=    Get Length    ${attrs}
    ${accept_length}=    Get Length    ${accept}
    ${options_length}=    Get Length    ${options}
    ${lang_length}=    Get Length    ${lang}
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
    IF    ${lang_length}>0    Set To Dictionary    ${params}    lang=${lang}

    ${response}=    GET
    ...    url=${url}/${ENTITIES_ENDPOINT_PATH}${id}
    ...    headers=${headers}
    ...    params=${params}
    ...    expected_status=any
    Output    ${response}    Query Entity
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
    Output    ${response}    Retrieve Attribute
    RETURN    ${response}

Retrieve Attributes
    [Arguments]    ${context}=${EMPTY}    ${details}=false    ${accept}=${EMPTY}

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
    Set To Dictionary    ${params}    details=${details}
    ${response}=    GET
    ...    url=${url}/${ATTRIBUTES_ENDPOINT_PATH}
    ...    headers=${headers}
    ...    params=${params}
    ...    expected_status=any
    Output    ${response}    Retrieve Attributes
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
    Output    ${response}    Retrieve Entity Type
    RETURN    ${response}

Retrieve Entity Types
    [Arguments]    ${context}=${EMPTY}    ${details}=false    ${accept}=${EMPTY}

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
    Set To Dictionary    ${params}    details=${details}
    ${response}=    GET
    ...    url=${url}/${ENTITIES_TYPES_ENDPOINT_PATH}/
    ...    headers=${headers}
    ...    params=${params}
    ...    expected_status=any
    Output    ${response}    Retrieve Entity Types
    RETURN    ${response}
