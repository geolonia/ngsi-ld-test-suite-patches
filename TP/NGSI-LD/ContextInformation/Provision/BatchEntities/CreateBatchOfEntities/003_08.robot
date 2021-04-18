*** Settings ***
Documentation     Check that an HTTP error response of type BadRequestData is raised if the Content-Type header is "application/ld+json" and the request payload body does not contain a @context term
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${building_id_prefix}=    urn:ngsi-ld:Building:

*** Test Case ***
Create a batch of one entity not containing a JSON-LD @context with a JSON-LD content type
    [Documentation]    Check that an HTTP error response of type BadRequestData is raised if the Content-Type header is "application/ld+json" and the request payload body does not contain a @context term
    [Tags]    be-create    6_3_5
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    ${entity}=    Load Entity    building-simple-attributes-sample.json    ${entity_id}
    @{entities_to_be_created}=    Create List    ${entity}
    Batch Create Entities    @{entities_to_be_created}    content_type=${CONTENT_TYPE_LD_JSON}
    Check Response Status Code Set To    400
    Check Response Body Containing ProblemDetails Element Containing Type Element set to    ${response}    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}
