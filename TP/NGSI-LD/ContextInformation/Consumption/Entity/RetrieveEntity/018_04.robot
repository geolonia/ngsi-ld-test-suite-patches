*** Settings ***
Documentation       Check that the queried entity by Id can be returned in a simplified representation

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:
${filename}=                building-simple-attributes-sample.jsonld
${expectation_filename}=    building-simple-attributes-simplified-expectation.jsonld
${options_parameter}=       keyValues


*** Test Cases ***
Get an entity in a simplified representation
    [Documentation]    Check that the queried entity by Id can be returned in a simplified representation
    [Tags]    e-retrieve    6_3_7
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response['status']}
    ${request}    ${response}=    Query Entity
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    ...    options=${options_parameter}
    Check Response Status Code    200    ${response['status']}
    Check Response Body Containing Entity element    ${expectation_filename}    ${entity_id}    ${response['body']}
    [Teardown]    Delete Entity by Id Returning Response    ${entity_id}
