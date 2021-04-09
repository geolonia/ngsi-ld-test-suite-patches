*** Settings ***
Documentation   Check that an HTTP error response of type BadRequestData is raised if the Content-Type header is "application/ld+json" and the request payload body does not contain a @context term
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:
${filename}=    building-simple-attributes-sample.json

*** Test Case ***
Create one entity not containing a JSON-LD @context with a JSON-LD content type
    [Documentation]  Check that an HTTP error response of type BadRequestData is raised if the Content-Type header is "application/ld+json" and the request payload body does not contain a @context term
    [Tags]   e-create    6_3_5

    ${entity_id}=     Generate Random Entity Id    ${building_id_prefix}

    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}

    Check Response Status Code  400     ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}
