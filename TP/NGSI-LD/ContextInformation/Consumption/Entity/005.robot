*** Settings ***
Documentation   Check that the queried entity by id can be returned in a geoJSON format
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:
${filename}=  building-location-attribute-sample.jsonld
${expectation_filename}=  building-simple-attributes-sample-expectation-simplified.jsonld
${options_parameter}=  keyValues
${accept_header}=  application/geo+json

*** Test Cases ***                                                 
005_Get an entity by id that can be returned in a geoJSON format       
    [Documentation]  Check that the queried entity by id can be returned in a geoJSON format
    [Tags]  mandatory    failing

    ${entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Query Entity    ${entity_id}    ${accept_header}    options=${options_parameter}
    Check Response Status Code  200    ${response['status']}
    Check Response Body Containing Entity element    ${expectation_filename}    ${entity_id}    ${response}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}