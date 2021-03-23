*** Settings ***
Documentation   Check that you can query several entities based on attribute names
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:
${filename}=  building-simple-attributes-sample.jsonld
${filename2}=  building-minimal-sample.jsonld
${expectation_filename}=  building-attributes-query-expectation.json
${entity_type}=  https://ngsi-ld-test-suite/context#Building
${attribute_airqualitylevel}=  https://ngsi-ld-test-suite/context#airQualityLevel
${attribute_subcategory}=  https://ngsi-ld-test-suite/context#subCategory

*** Test Cases ***                                                 
Query several entities based on attribute names
    [Documentation]  Check that you can query several entities based on attribute names
    [Tags]  /entities/    5_7_2

    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${first_entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}
    ${second_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename2}     ${second_entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${attributes_to_be_retrieved}=  Catenate    SEPARATOR=,   ${attribute_airqualitylevel}  ${attribute_subcategory}
    @{entities_ids_to_be_compared}=  Create List     ${first_entity_id}
    ${response}=    Query Entities    attrs=${attributes_to_be_retrieved}
    Check Response Status Code  200    ${response['status']}
    Check Response Body Containing List Containing Entity elements    ${expectation_filename}    ${entities_ids_to_be_compared}    ${response['body']}

    [Teardown]  Delete Entities    ${first_entity_id}    ${second_entity_id}


*** Keywords ***
Delete Entities
    [Arguments]  ${first_entity_id}    ${second_entity_id}
    Delete Entity by Id Returning Response   ${first_entity_id}
    Delete Entity by Id Returning Response   ${second_entity_id}