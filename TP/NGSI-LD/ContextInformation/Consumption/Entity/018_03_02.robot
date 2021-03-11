*** Settings ***
Documentation   Check that you cannot get an entity if an attribute is not known to the system
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:
${filename}=  building-simple-attributes-sample.jsonld
${attribute_not_known}=  property_not_found

*** Test Cases ***                                                 
Get an entity if an atris not known to the system           
    [Documentation]  Check that you cannot get an entity if an attribute is not known to the system
    [Tags]  mandatory

    ${entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${attributes_to_be_retrieved}=  Create List      ${attribute_not_known}
    ${request}    ${response}=    Query Entity    ${entity_id}    ${CONTENT_TYPE_LD_JSON}    attrs=${attributes_to_be_retrieved}
    Check Response Status Code  404    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_RESOURCE_NOT_FOUND}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}