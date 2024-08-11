*** Settings ***
Documentation       Check that one can create an entity with operationSpace geospatial Property

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Teardown       Delete Initial Entity


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:
${filename}=                building-operation-space-geoproperty.jsonld
${content_type}=            application/ld+json


*** Test Cases ***
001_13 Create Entity With operationSpace Geospatial Property
    [Documentation]    Check that one can create an entity with operationSpace geospatial Property
    [Tags]    e-create    5_6_1    4_7

    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    Set Test Variable    ${entity_id}

    ${response}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${entity_id}
    ...    ${content_type}

    Check Response Status Code    201    ${response.status_code}
    Check Response Headers Containing URI set to    ${entity_id}    ${response.headers}
    ${created_entity}=    Load Test Sample    entities/${filename}    ${entity_id}
    ${response1}=    Retrieve Entity by Id
    ...    id=${entity_id}
    ...    context=${ngsild_test_suite_context}
    Check Created Resource Set To
    ...    created_resource=${created_entity}
    ...    response_body=${response1.json()}


*** Keywords ***
Delete Initial Entity
    Delete Entity by Id    ${entity_id}
