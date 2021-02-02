*** Settings ***
Documentation   Check that you can query several entities via POST Interaction based on attribute names
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:
${filename}=  building-minimal-sample.jsonld
${expectation_filename}=  building-minimal-sample-expectation.jsonld
${entity_type}=  https://uri.fiware.org/ns/data-models#Building
${attribute_airqualitylevel}=  https://uri.fiware.org/ns/data-models#airQualityLevel
${attribute_subcategory}=  https://uri.fiware.org/ns/data-models#subCategory

*** Test Cases ***                                                 
Query several entities via POST Interaction based on attribute names
    [Documentation]  Check that you can query several entities via POST Interaction based on attribute names
    [Tags]  mandatory    failing

    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${first_entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}
    ${second_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${second_entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    @{attributes_to_be_retrieved}=  Create List      ${attribute_airqualitylevel}  ${attribute_subcategory}
    @{entities_ids_to_be_retrieved}=  Create List   ${first_entity_id}    ${second_entity_id}
    ${response}=    Query Entities Via POST    attrs=${attributes_to_be_retrieved}
    Check Response Status Code  200    ${response['status']}
    Check Response Body Containing List Containing Entity elements    ${expectation_filename}    ${entities_ids_to_be_retrieved}    ${response['body']}

    [Teardown]  Delete Entities    ${first_entity_id}    ${second_entity_id}


*** Keywords ***
Delete Entities
    [Arguments]  ${first_entity_id}    ${second_entity_id}
    Delete Entity by Id Returning Response   ${first_entity_id}
    Delete Entity by Id Returning Response   ${second_entity_id}