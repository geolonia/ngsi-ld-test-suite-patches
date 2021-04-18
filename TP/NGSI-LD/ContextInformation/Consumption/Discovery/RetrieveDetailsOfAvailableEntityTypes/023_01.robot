*** Settings ***
Documentation     Check that you can retrieve a list with a detailed representation of NGSI-LD entity types
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Test Template     Retrieve Details Of Available Entity Types
Suite Setup       Setup Initial Entities
Suite Teardown    Delete Initial Entities

*** Variable ***
${building_id_prefix}=    urn:ngsi-ld:Building:
${vehicle_id_prefix}=    urn:ngsi-ld:Vehicle:
${first_filename}=    building-simple-attributes-sample.json
${second_filename}=    vehicle-simple-attributes-sample.json

*** Test Cases ***    CONTEXT                         EXPECTATION_FILE
WithoutJsonLdContext
                      ${EMPTY}                        types/expectations/entity-type-023-01-01-expectation.json
                      [Tags]                          ed-types-details                                             5_7_6

WithJsonLdContext     ${ngsild_test_suite_context}    types/expectations/entity-type-023-01-02-expectation.json
                      [Tags]                          ed-types-details                                             5_7_6

*** Keywords ***
Retrieve Details Of Available Entity Types
    [Arguments]    ${context}    ${expectation_file}
    [Documentation]    Check that you can retrieve a list with a detailed representation of NGSI-LD entity types
    Retrieve Entity Types    context=${context}    details=${TRUE}
    Check Response Status Code Set To    200
    Check Response Body Containing EntityType element    ${expectation_file}

Setup Initial Entities
    ${first_entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    ${second_entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    Create Entity Selecting Content Type    ${first_filename}    ${first_entity_id}    ${CONTENT_TYPE_JSON}    ${ngsild_test_suite_context}
    Create Entity Selecting Content Type    ${second_filename}    ${second_entity_id}    ${CONTENT_TYPE_JSON}    ${ngsild_test_suite_context}
    Set Suite Variable    ${first_entity_id}
    Set Suite Variable    ${second_entity_id}

Delete Initial Entities
    Delete Entity by Id Returning Response    ${first_entity_id}
    Delete Entity by Id Returning Response    ${second_entity_id}
