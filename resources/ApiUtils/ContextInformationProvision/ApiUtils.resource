*** Settings ***
Variables       ${EXECDIR}/resources/variables.py
Library         ${EXECDIR}/libraries/logUtils.py
Library         RequestsLibrary
Library         OperatingSystem
Library         Collections
Library         JSONLibrary


*** Variables ***
${ENTITIES_ENDPOINT_PATH}           entities/

${CONTENT_TYPE_LD_JSON}             application/ld+json

${ERROR_TYPE_ALREADY_EXISTS}        https://uri.etsi.org/ngsi-ld/errors/AlreadyExists
${ERROR_TYPE_BAD_REQUEST_DATA}      https://uri.etsi.org/ngsi-ld/errors/BadRequestData
${ERROR_TYPE_INVALID_REQUEST}       https://uri.etsi.org/ngsi-ld/errors/InvalidRequest
${ERROR_TYPE_RESOURCE_NOT_FOUND}    https://uri.etsi.org/ngsi-ld/errors/ResourceNotFound


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
