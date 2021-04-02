*** Settings ***
Documentation   Check that you can retrieve a detailed representation of a specified NGSI-LD entity type
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Suite Setup      Setup Initial Entities
Suite Teardown      Delete Initial Entities

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:
${filename}=  building-simple-attributes-sample.json
${expectation_file}=  types/expectations/entity-type-info-024-01-expectation.json

*** Test Case ***
Retrieve Detailed Representation Of Available Entity Type
    [Documentation]  Check that you can retrieve a detailed representation of a specified NGSI-LD entity type
    [Tags]   ed-type    5_7_7

    Retrieve Entity Type   type=Building    context=${ngsild_test_suite_context}

    Check Response Status Code Set To  200
    Check Response Body Containing EntityTypeInfo element   ${expectation_file}

*** Keywords ***
Setup Initial Entities
    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${second_entity_id}=     Generate Random Entity Id    ${building_id_prefix}

    Create Entity Selecting Content Type  ${filename}     ${first_entity_id}    ${CONTENT_TYPE_JSON}    ${ngsild_test_suite_context}
    Create Entity Selecting Content Type  ${filename}     ${second_entity_id}    ${CONTENT_TYPE_JSON}    ${ngsild_test_suite_context}

    Set Suite Variable  ${first_entity_id}
    Set Suite Variable  ${second_entity_id}

Delete Initial Entities
    Delete Entity by Id Returning Response   ${first_entity_id}
    Delete Entity by Id Returning Response   ${second_entity_id}