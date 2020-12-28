*** Settings ***
Documentation   Check that you can get an entity by id
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:

*** Test Cases ***                               
001_01_Check that you can get an entity by id
    [Documentation]  Check that you can get an entity by id
    [Tags]  mandatory

    ${entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  building-simple-attributes-sample.jsonld     ${entity_id}    application/ld+json
    Check Response Status Code  201    ${response['status']}

    ${response}=    Retrieve Entity by Id Returning Response    ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  200    ${response['status']}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}