*** Settings ***
Documentation   Check that you can query the geometry property from an entity
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:
${filename}=  building-location-attribute-sample.jsonld
${expectation_filename}=  building-location-attribute-sample-expectation-query-geoproperty.jsonld
${geometry_property}=  test

*** Test Cases ***                               
001_03_Query the geometry property from an entity
    [Documentation]  Check that you can query the geometry property from an entity
    [Tags]  mandatory

    ${entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Query Entity    ${entity_id}    ${CONTENT_TYPE_LD_JSON}    geoproperty=${geometry_property}
    Check Response Status Code  200    ${response['status']}
    Check Response Body Containing Entity element    ${expectation_filename}    ${entity_id}    ${response['body']}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}