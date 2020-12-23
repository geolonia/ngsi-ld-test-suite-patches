*** Settings ***
Documentation   Check that you cannot create an entity with and existing id
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:
${expected_error_message}=  Already exists.
${filename}=  building-minimal-sample.jsonld
${content_type}=  application/ld+json

*** Test Case ***
Create one valid entity and one invalid entity
    [Documentation]  Check that you cannot create an entity with and existing id
    [Tags]  mandatory

    ${entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    Create Entity Selecting Content Type   ${filename}    ${entity_id}    ${content_type}
    Check Response Status Code Set To  201

    #creating entity with the same id
    Create Entity Selecting Content Type   ${filename}    ${entity_id}    ${content_type}
    Check Response Status Code Set To  409
    Check Response Body Details Containing Information Error  ${expected_error_message}

    [Teardown]    Delete Entity by Id       ${entity_id}

