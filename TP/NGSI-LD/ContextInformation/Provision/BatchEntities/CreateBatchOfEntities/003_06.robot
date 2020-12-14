*** Settings ***
Documentation   Check that an HTTP error response of type BadRequestData is raised if the Content-Type header is "application/json" and the request payload body (as JSON) contains a "@context" term
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:

*** Test Case ***
Create a batch of one entity containing a JSON-LD @context with a JSON content type
    [Documentation]  Check that an HTTP error response of type BadRequestData is raised if the Content-Type header is "application/json" and the request payload body (as JSON) contains a "@context" term
    [Tags]  mandatory

    ${entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${entity}=    Load Entity    building-simple-attributes-sample.jsonld      ${entity_id}
    @{entities_to_be_created}=  Create List   ${entity}

    Batch Create Entities   @{entities_to_be_created}       content_type=${CONTENT_TYPE_JSON}

    Check Response Status Code Set To  400
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}
