*** Settings ***
Documentation   Check that you can delete an entity by id
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

#Suite Setup      Setup Initial Entity

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:

*** Test Case ***
Delete an entity
    [Documentation]  Check that you can delete an entity by id
    [Tags]  mandatory

    ${entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    Create Entity Selecting Content Type  building-simple-attributes-sample.jsonld     ${entity_id}    application/ld+json

    ${response}=    Delete Entity by Id Returning Response   ${entity_id}
    Should Be Equal  204    ${response['status']}

#*** Keywords ***
#Setup Initial Entity
#    ${entity_id}=     Generate Random Entity Id    ${building_id_prefix}
#    Create Entity  building-simple-attributes-sample.jsonld     ${entity_id}
#    Set Suite Variable  ${entity_id}
