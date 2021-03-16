*** Settings ***
Documentation   Check that you can create an entity
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Create Entity Scenarios

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:

*** Test Cases ***                                  FILENAME                                              CONTENT_TYPE
001_01_01_MinimalEntity                             building-minimal-without-context-sample.jsonld        application/json
001_01_02_EntityWithSimpleProperties                building-simple-attributes-sample.jsonld              application/ld+json
001_01_03_EntityWithRelationshipsProperties         building-relationship-of-property-sample.jsonld       application/ld+json
001_01_04_EntityWithLocationAttribute               building-location-attribute-sample.jsonld             application/ld+json

*** Keywords ***
Create Entity Scenarios
    [Arguments]  ${filename}    ${content_type}
    [Documentation]  Check that you can create an entity
    [Tags]  /entities/    5_6_1

    ${entity_id}=     Generate Random Entity Id    ${building_id_prefix}

    ${request}    ${response}=    Create Entity Selecting Content Type   ${filename}      ${entity_id}     ${content_type}
    Check Response Status Code  201    ${response['status']}
    Check Response Headers Containing URI set to    ${request['path']}    ${entity_id}    ${response}

    ${created_entity}=    Load Test Sample    entities/${filename}      ${entity_id}
    Run Keyword If     '${content_type}'=='application/json'     Retrieve Entity by Id    ${entity_id}    ${content_type}
    Run Keyword If     '${content_type}'=='application/ld+json'     Retrieve Entity by Id    ${entity_id}    ${content_type}     context=${ngsild_test_suite_context}
    Check Created Resource Set To     ${created_entity}

    [Teardown]    Delete Entity by Id       ${entity_id}