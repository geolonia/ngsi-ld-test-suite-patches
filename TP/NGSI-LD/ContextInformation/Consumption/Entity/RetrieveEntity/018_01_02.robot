*** Settings ***
Documentation   Check that you can query some attributes from an entity
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:
${filename}=  building-simple-attributes-sample.jsonld
${expectation_filename}=  building-simple-attributes-query-expectation.jsonld
${attribute_airqualitylevel}=  https://ngsi-ld-test-suite/context#airQualityLevel
${attribute_subcategory}=  https://ngsi-ld-test-suite/context#subCategory

*** Test Cases ***                               
018_01_02_Query some attributes from an entity
    [Documentation]  Check that you can query some attributes from an entity
    [Tags]  e-retrieve    5_7_1

    ${entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${attributes_to_be_retrieved}=  Catenate    SEPARATOR=,     ${attribute_airqualitylevel}    ${attribute_subcategory}
    ${request}    ${response}=    Query Entity    ${entity_id}    ${CONTENT_TYPE_LD_JSON}    attrs=${attributes_to_be_retrieved}
    Check Response Status Code  200    ${response['status']}
    Check Response Body Containing Entity element    ${expectation_filename}    ${entity_id}    ${response['body']}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}