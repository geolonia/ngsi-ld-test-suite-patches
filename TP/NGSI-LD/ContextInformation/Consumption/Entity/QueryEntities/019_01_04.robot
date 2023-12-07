*** Settings ***
Documentation       Check that you can query several entities based on attribute names

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Teardown      Delete Entities


*** Variables ***
${building_id_prefix}=              urn:ngsi-ld:Building:
${filename}=                        building-simple-attributes-sample.jsonld
${filename2}=                       building-minimal-sample.jsonld
${expectation_filename}=            building-attributes-query-expectation.json
${entity_type}=                     https://ngsi-ld-test-suite/context#Building
${attribute_airqualitylevel}=       https://ngsi-ld-test-suite/context#airQualityLevel
${attribute_subcategory}=           https://ngsi-ld-test-suite/context#subCategory


*** Test Cases ***
019_01_04 Query several entities based on attribute names
    [Documentation]    Check that you can query several entities based on attribute names
    [Tags]    e-query    5_7_2
    ${first_entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Suite Variable    ${first_entity_id}
    ${create_response1}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${first_entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${create_response1.status_code}
    ${second_entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Suite Variable    ${second_entity_id}
    ${create_response2}=    Create Entity Selecting Content Type
    ...    ${filename2}
    ...    ${second_entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${create_response2.status_code}
    ${attributes_to_be_retrieved}=    Catenate
    ...    SEPARATOR=,
    ...    ${attribute_airqualitylevel}
    ...    ${attribute_subcategory}
    @{entities_ids_to_be_compared}=    Create List    ${first_entity_id}
    ${response}=    Query Entities    attrs=${attributes_to_be_retrieved}
    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing List Containing Entity Elements
    ...    ${expectation_filename}
    ...    ${entities_ids_to_be_compared}
    ...    ${response.json()}


*** Keywords ***
Delete Entities
    Delete Entity by Id    ${first_entity_id}
    Delete Entity by Id    ${second_entity_id}
