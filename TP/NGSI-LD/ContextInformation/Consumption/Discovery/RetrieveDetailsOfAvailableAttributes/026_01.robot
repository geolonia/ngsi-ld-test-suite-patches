*** Settings ***
Documentation   Check that you can retrieve a list with a detailed representation of NGSI-LD attributes
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Retrieve Details Of Available Attributes
Suite Setup      Setup Initial Entities
Suite Teardown      Delete Initial Entities

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:
${filename}=  building-simple-attributes-sample.json

*** Test Cases ***          CONTEXT                         EXPECTATION_FILE
WithoutJsonLdContext        ${EMPTY}                        types/expectations/attribute-026-01-01-expectation.json
    [Tags]   ed-attrs-details    5_7_9
WithJsonLdContext           ${ngsild_test_suite_context}    types/expectations/attribute-026-01-02-expectation.json
    [Tags]   ed-attrs-details    5_7_9

*** Keywords ***
Retrieve Details Of Available Attributes
    [Arguments]  ${context}     ${expectation_file}
    [Documentation]  Check that you can retrieve a list with a detailed representation of NGSI-LD attributes

    Retrieve Attributes   context=${context}    details=${TRUE}

    Check Response Status Code Set To  200
    Check Response Body Containing Attribute element   ${expectation_file}

Setup Initial Entities
    ${entity_id}=     Generate Random Entity Id    ${building_id_prefix}

    Create Entity Selecting Content Type  ${filename}     ${entity_id}    ${CONTENT_TYPE_JSON}    ${ngsild_test_suite_context}

    Set Suite Variable  ${entity_id}

Delete Initial Entities
    Delete Entity by Id Returning Response   ${entity_id}
