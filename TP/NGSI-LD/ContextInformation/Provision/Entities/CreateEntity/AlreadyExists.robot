*** Settings ***
Documentation   Check that the IUT refuses to create an entity if one exists with the same identifier 
Variables   ../../../../../../resources/variables.py
#Resource    ../../../../../../resources/ApiUtils.resource
Library     REST    ${url}
Library     JSONSchemaLibrary   ${EXECDIR}/schemas
Library     BuiltIn

#Suite Setup      Create Entity  building-minimal.jsonld
#Suite Teardown   Delete Entity by Id  urn:ngsi-ld:Building:3009ef20-9f62-41f5-bd66-92f041b428b9

*** Variable ***
${endpoint}=    entities

*** Test Case ***
AlreadyExists
    [Documentation]  Check that the IUT refuses to create an entity if one exists with the same identifier 
    [Tags]  critical  
    Create Entity  building-minimal.jsonld
    Create Entity  building-minimal.jsonld
    Check HTTP Status Code Is  409
    Check HTTP Response Body Json Schema Is  error_response
    Delete Entity by Id  urn:ngsi-ld:Building:3009ef20-9f62-41f5-bd66-92f041b428b9

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

Check HTTP Response Body Json Schema Is
    [Arguments]  ${input}
    Should Contain  ${response['headers']['Content-Type']}  application/json
    ${schema}=  Catenate  SEPARATOR=  ${input}  .schema.json
    Validate Json  ${schema}  ${response['body']}
    Log  Json Schema Validation OK

Delete Entity by Id
    [Arguments]  ${id}
    ${response}=  DELETE  ${endpoint}/${id}
    Output  request
    Output  response