*** Settings ***
Documentation       Check that an HTTP error response of type BadRequestData is raised if the Content-Type header is "application/json" and the request payload body (as JSON) contains a "@context" term

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource


*** Variables ***
${registration_id_prefix}=              urn:ngsi-ld:Registration:
${registration_payload_file_path}=      csourceRegistrations/context-source-registration-simple-sample.jsonld


*** Test Cases ***
Create one context source registration containing a JSON-LD @context with a JSON content type
    [Documentation]    Check that an HTTP error response of type BadRequestData is raised if the Content-Type header is "application/json" and the request payload body (as JSON) contains a "@context" term
    [Tags]    csr-create    6_3_5
    ${registration_id}=    Generate Random Entity Id    ${registration_id_prefix}
    ${payload}=    Load JSON From File    ${EXECDIR}/data/${registration_payload_file_path}
    ${updated_payload}=    Update Value To JSON    ${payload}    $..id    ${registration_id}
    ${request}    ${response}=    Create Context Source Registration With Return
    ...    ${updated_payload}
    ...    ${CONTENT_TYPE_JSON}
    Check Response Status Code    400    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response}
    ...    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}
