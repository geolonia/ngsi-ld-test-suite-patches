*** Settings ***
Documentation   Check that you cannot create an entity with an existing id
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:
${filename}=  building-minimal-sample.jsonld
${content_type}=  application/ld+json

*** Test Case ***
Create one valid entity and one invalid entity
    [Documentation]  Check that you cannot create an entity with an existing id
    [Tags]   e-create    5_6_1

    ${entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type   ${filename}    ${entity_id}    ${content_type}
    Check Response Status Code  201    ${response['status']}

    ${request}    ${response}=    Create Entity Selecting Content Type   ${filename}    ${entity_id}    ${content_type}
    Check Response Status Code  409    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_ALREADY_EXISTS}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}

    [Teardown]    Delete Entity by Id       ${entity_id}

