*** Settings ***
Variables       ${EXECDIR}/resources/variables.py
Library         ${EXECDIR}/libraries/logUtils.py
Library         Collections
Library         RequestsLibrary
Library         OperatingSystem


*** Variables ***
${JSONLDCONTEXTS_ENDPOINT_PATH}     jsonldContexts

${CONTENT_TYPE_JSON}                application/json

${response}                         ${EMPTY}

@{ALLOWED_CONTEXT}                  Cached    Hosted    ImplicitlyCreated    UserCreated

${ERROR_OPERATION_NOT_SUPPORTED}    https://uri.etsi.org/ngsi-ld/errors/OperationNotSupported
${ERROR_TYPE_BAD_REQUEST_DATA}      https://uri.etsi.org/ngsi-ld/errors/BadRequestData


*** Keywords ***
Add a new @context
    [Arguments]    ${filename}

    ${file_content}=    Get File    ${EXECDIR}/data/jsonldContext/${filename}

    &{headers}=    Create Dictionary    Content-Type=application/json
    ${response}=    POST
    ...    url=${url}/${JSONLDCONTEXTS_ENDPOINT_PATH}
    ...    data=${file_content}
    ...    headers=${headers}
    ...    expected_status=any

    Output    ${response}    Add a new @context
    RETURN    ${response}

Serve a @context
    [Arguments]    ${contextId}    ${details}=${EMPTY}

    IF    '${details}'!=''
        &{params}=    Create Dictionary
        Set To Dictionary    ${params}    details=${details}

        ${response}=    GET
        ...    url=${url}/${JSONLDCONTEXTS_ENDPOINT_PATH}/${contextId}
        ...    params=${params}
        ...    expected_status=any
    ELSE
        ${response}=    GET
        ...    url=${url}/${JSONLDCONTEXTS_ENDPOINT_PATH}/${contextId}
        ...    expected_status=any
    END

    Output    ${response}    Serve a @context
    RETURN    ${response}

Delete a @context
    [Arguments]    ${contextId}    ${reload}=${EMPTY}

    IF    '${reload}'!=''
        &{params}=    Create Dictionary
        Set To Dictionary    ${params}    reload=${reload}

        ${response}=    DELETE
        ...    url=${url}/${JSONLDCONTEXTS_ENDPOINT_PATH}/${contextId}
        ...    params=${params}
        ...    expected_status=any
    ELSE
        ${response}=    DELETE
        ...    url=${url}/${JSONLDCONTEXTS_ENDPOINT_PATH}/${contextId}
        ...    expected_status=any
    END

    Output    ${response}    Delete a @context
    RETURN    ${response}

List @contexts
    [Arguments]    ${details}=${EMPTY}    ${kind}=${EMPTY}

    &{params}=    Create Dictionary

    IF    '${details}'=='' and '${kind}'==''
        ${response}=    GET
        ...    url=${url}/${JSONLDCONTEXTS_ENDPOINT_PATH}
        ...    expected_status=any
    ELSE
        IF    '${details}'!=''
            Set To Dictionary    ${params}    details=${details}
        END

        IF    '${kind}'!=''    Set To Dictionary    ${params}    kind=${kind}

        ${string_list}=    Evaluate    [f'{key}={value}' for key, value in ${params}.items()]
        ${params_as_string}=    Evaluate    '&'.join(${string_list})

        ${response}=    GET
        ...    url=${url}/${JSONLDCONTEXTS_ENDPOINT_PATH}?${params_as_string}
        ...    expected_status=any
    END

    Output    ${response}    List @contexts
    RETURN    ${response}
