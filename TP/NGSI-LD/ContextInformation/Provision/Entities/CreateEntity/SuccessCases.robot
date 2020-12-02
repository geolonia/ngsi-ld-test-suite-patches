*** Settings ***
Documentation   Check that the IUT accepts the creation of an entity
Variables   ../../../../../../resources/variables.py
#Resource    ../../../../../../resources/ApiUtils.resource
Library     REST    ${url}

*** Variable ***
${endpoint}=    entities
${id}=  urn:ngsi-ld:Building:3009ef20-9f62-41f5-bd66-92f041b428b9

*** Test Case ***
SuccessCases_MinimalEntity
    [Documentation]  Create an entity with a JSON-LD payload containing the minimal information
    [Tags]  critical
    Create Entity  building-minimal.jsonld
    Check HTTP Status Code Is  201
    Delete Entity by Id  ${id}

SuccessCases_EntityWithSimpleProperties
    [Documentation]  Create an entity with a JSON-LD payload containing only simple properties
    Create Entity  building-simple-attributes.jsonld
    Check HTTP Status Code Is  201
    Delete Entity by Id  ${id}


*** Keywords ***
Create Entity
    [Arguments]  ${filename}
    &{headers}=  Create Dictionary  Content-Type=application/ld+json
    ${response}=  POST  ${endpoint}  body=${EXECDIR}/data/entities/${filename}  headers=${headers}
    Output  request
    Output  response
    Set Test Variable  ${response}

Check HTTP Status Code Is
    [Arguments]  ${status}
    ${response_status}=  convert to string  ${response['status']}
    Should Be Equal  ${response_status}  ${status}

Delete Entity by Id
    [Arguments]  ${id}
    ${response}=  DELETE  ${endpoint}/${id}
    Output  request
    Output  response
