*** Settings ***
Variables       ${EXECDIR}/resources/variables.py
Library         ${EXECDIR}/libraries/logUtils.py
Library         Collections
Library         JSONLibrary
Library         RequestsLibrary


*** Variables ***
${ATTRIBUTES_ENDPOINT_PATH}         attributes
${ENTITIES_ENDPOINT_PATH}           entities/
${ENTITIES_TYPES_ENDPOINT_PATH}     types

${CONTENT_TYPE_JSON}                application/json
${CONTENT_TYPE_LD_JSON}             application/ld+json

${ERROR_TYPE_BAD_REQUEST_DATA}      https://uri.etsi.org/ngsi-ld/errors/BadRequestData
${ERROR_TYPE_RESOURCE_NOT_FOUND}    https://uri.etsi.org/ngsi-ld/errors/ResourceNotFound


*** Keywords ***
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

Delete Entity by Id Returning Response
    [Arguments]    ${id}
    ${response}=    DELETE    url=${url}/${ENTITIES_ENDPOINT_PATH}${id}    expected_status=any
    Output    ${response}    Delete Entity by Id Returning Response
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
    Output    ${response}    Retrieve Attributes
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
    Output    ${response}    Retrieve Entity Types
    RETURN    ${response}
