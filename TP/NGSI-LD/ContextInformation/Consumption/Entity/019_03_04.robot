*** Settings ***
Documentation   Check that you cannot query entities if the requested attribute names are incorrect
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:
${filename}=  building-minimal-sample.jsonld
${entity_type}=  https://ngsi-ld-test-suite/context#Building
${invalid_attribute_one}=  invalid_attribute_one
${invalid_attribute_two}=  invalid_attribute_two

*** Test Cases ***                                                 
Query several entities based on incorrect attribute names
    [Documentation]  Check that you cannot query entities if the requested attribute names are incorrect
    [Tags]  mandatory

    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${first_entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}
    ${second_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${second_entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${attributes_to_be_retrieved}=  Catenate    SEPARATOR=,   ${invalid_attribute_one}    ${invalid_attribute_two}
    ${response}=    Query Entities    attrs=${attributes_to_be_retrieved}
    Check Response Status Code  400    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}

    [Teardown]  Delete Entities    ${first_entity_id}    ${second_entity_id}


*** Keywords ***
Delete Entities
    [Arguments]  ${first_entity_id}    ${second_entity_id}
    Delete Entity by Id Returning Response   ${first_entity_id}
    Delete Entity by Id Returning Response   ${second_entity_id}