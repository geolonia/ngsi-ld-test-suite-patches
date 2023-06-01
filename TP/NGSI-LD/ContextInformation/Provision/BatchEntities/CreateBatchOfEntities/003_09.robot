*** Settings ***
Documentation       Check that an HTTP error response of type BadRequestData is raised if the Content-Type header is "application/ld+json" and a JSON-LD Link header is present in the incoming HTTP request

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:


*** Test Cases ***
Create a batch of one entity with a Link header and a JSON-LD content type
    [Documentation]    Check that an HTTP error response of type BadRequestData is raised if the Content-Type header is "application/ld+json" and a JSON-LD Link header is present in the incoming HTTP request
    [Tags]    be-create    6_3_5
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    ${entity}=    Load Entity    building-simple-attributes-sample.jsonld    ${entity_id}
    @{entities_to_be_created}=    Create List    ${entity}
    ${response}=    Batch Create Entities
    ...    @{entities_to_be_created}
    ...    content_type=${CONTENT_TYPE_LD_JSON}
    ...    context=${ngsild_test_suite_context}
    Check Response Status Code    400    ${response.status_code}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()}
    ...    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}
