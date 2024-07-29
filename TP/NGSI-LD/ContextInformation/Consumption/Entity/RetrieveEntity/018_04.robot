*** Settings ***
Documentation       Check that the queried entity by Id can be returned in a simplified representation

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Create Entity
Test Teardown       Delete Created Entity


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:
${filename}=                building-simple-attributes.jsonld
${expectation_filename}=    building-simple-attributes-simplified.jsonld
${options_parameter}=       keyValues


*** Test Cases ***
018_04_01 Get an entity in a simplified representation
    [Documentation]    Check that the queried entity by Id can be returned in a simplified representation
    [Tags]    e-retrieve    6_3_7
    ${response}=    Query Entity
    ...    id=${entity_id}
    ...    accept=${CONTENT_TYPE_LD_JSON}
    ...    options=${options_parameter}

    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing Entity element
    ...    ${expectation_filename}
    ...    ${entity_id}
    ...    ${response.json()}
    ...    ${True}


*** Keywords ***
Create Entity
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Test Variable    ${entity_id}
    ${create_response}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${create_response.status_code}

Delete Created Entity
    Delete Entity by Id    ${entity_id}
