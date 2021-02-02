*** Settings ***
Documentation   Check that you can delete an entity by id
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:

*** Test Case ***
Delete an entity
    [Documentation]  Check that you can delete an entity by id
    [Tags]  mandatory

    ${entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  building-simple-attributes-sample.jsonld     ${entity_id}    application/ld+json
    Check Response Status Code  201    ${response['status']}

    ${response}=    Delete Entity by Id Returning Response   ${entity_id}
    Check Response Status Code  204    ${response['status']}
