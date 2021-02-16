*** Settings ***
Documentation   Check that an HTTP error response of type BadRequestData is raised if the Content-Type header is "application/ld+json" and a JSON-LD Link header is present in the incoming HTTP request
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource


*** Variable ***
${registration_id_prefix}=  urn:ngsi-ld:Registration:
${registration_payload_file_path}=   csourceRegistrations/context-source-registration-sample.jsonld

*** Test Case ***
Create one context source registration with a Link header and a JSON-LD content type
    [Documentation]  Check that an HTTP error response of type BadRequestData is raised if the Content-Type header is "application/ld+json" and a JSON-LD Link header is present in the incoming HTTP request
    [Tags]  mandatory
    ${registration_id}=     Generate Random Entity Id    ${registration_id_prefix}

    ${payload}=    Load Json From File    ${EXECDIR}/data/${registration_payload_file_path}
    ${updated_payload}=    Update Value To Json    ${payload}     $..id   ${registration_id}
    ${request}    ${response}=    Create Context Source Registration With Return  ${updated_payload}    ${CONTENT_TYPE_LD_JSON}         ${ngsild_test_suite_context}

    Check Response Status Code  400     ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}
