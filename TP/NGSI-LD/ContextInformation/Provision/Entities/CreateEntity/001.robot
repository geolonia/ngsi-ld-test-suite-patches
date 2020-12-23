*** Settings ***
Documentation   Check that you can create an entity
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Create Entity Scenarios

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:

*** Test Cases ***                        FILENAME                                              CONTENT_TYPE
MinimalEntity                             building-minimal-without-context-sample.jsonld        application/json
EntityWithSimpleProperties                building-simple-attributes-sample.jsonld              application/ld+json
EntityWithRelationshipsProperties         building-relationship-of-property-sample.jsonld       application/ld+json
#EntityWithNoContext                       building-minimal-without-context-sample.jsonld        application/ld+json
EntityWithLocationAttribute               building-location-attribute.jsonld                    application/ld+json



*** Keywords ***
Create Entity Scenarios
    [Arguments]  ${filename}    ${content_type}
    [Documentation]  Check that you can create an entity
    [Tags]  mandatory   entityOperations

    ${entity_id}=     Generate Random Entity Id    ${building_id_prefix}

    Create Entity Selecting Content Type   ${filename}      ${entity_id}     ${content_type}
    Check Response Status Code Set To  201
    Check Response Headers Containing URI set to    ${request['path']}    ${entity_id}

    [Teardown]    Delete Entity by Id       ${entity_id}