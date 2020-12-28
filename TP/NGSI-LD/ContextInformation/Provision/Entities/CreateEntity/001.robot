*** Settings ***
Documentation   Check that you can create an entity
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Create Entity Scenarios

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:

*** Test Cases ***                        FILENAME                                              CONTENT_TYPE
001_01_MinimalEntity                             building-minimal-without-context-sample.jsonld        application/json
001_02_EntityWithSimpleProperties                building-simple-attributes-sample.jsonld              application/ld+json
001_03_EntityWithRelationshipsProperties         building-relationship-of-property-sample.jsonld       application/ld+json
#001_04_EntityWithNoContext                       building-minimal-without-context-sample.jsonld        application/ld+json
001_05_EntityWithLocationAttribute               building-location-attribute.jsonld                    application/ld+json



*** Keywords ***
Create Entity Scenarios
    [Arguments]  ${filename}    ${content_type}
    [Documentation]  Check that you can create an entity
    [Tags]  mandatory   entityOperations

    ${entity_id}=     Generate Random Entity Id    ${building_id_prefix}

    ${request}    ${response}=    Create Entity Selecting Content Type   ${filename}      ${entity_id}     ${content_type}
    Check Response Status Code  201    ${response['status']}
    Check Response Headers Containing URI set to    ${request['path']}    ${entity_id}    ${response}

    [Teardown]    Delete Entity by Id       ${entity_id}