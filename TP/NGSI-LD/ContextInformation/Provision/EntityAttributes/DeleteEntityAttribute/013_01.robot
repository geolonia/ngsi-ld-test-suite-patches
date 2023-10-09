*** Settings ***
Documentation       Check that you can delete an attribute from an entity

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision/ApiUtils.resource
# Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Teardown       Delete Initial Entities
Test Template       Delete Attributes


*** Variables ***
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:
${status_code}=             204
${filename}=                vehicle-two-datasetid-attributes-sample.jsonld
${attribute_id}=            speed


*** Test Cases ***    DATASETID    DELETEALL    EXPECTATION_FILENAME
013_01_01 delete an attribute with the default instance
    ${EMPTY}    false    vehicle-delete-default-speed-expectation.jsonld
013_01_02 delete an attribute with the datasetId
    urn:ngsi-ld:Property:gpsBxyz123-speed    false    vehicle-delete-datasetid-speed-expectation.jsonld
013_01_03 delete all target attribute instances
    ${EMPTY}    true    vehicle-delete-deleteall-speed-expectation.jsonld


*** Keywords ***
Delete Attributes
    [Documentation]    Check that you can delete an attribute from an entity
    [Tags]    ea-delete    5_6_5
    [Arguments]    ${datasetId}    ${deleteAll}    ${expectation_filename}
    ${entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    Set Test Variable    ${entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Delete Entity Attributes
    ...    ${entity_id}
    ...    ${attribute_id}
    ...    ${datasetId}
    ...    ${deleteAll}
    ...    ${ngsild_test_suite_context}
    Check Response Status Code    ${status_code}    ${response.status_code}
    ${entity_expectation_payload}=    Load Test Sample    entities/expectations/${expectation_filename}    ${entity_id}
    ${response}=    Retrieve Entity by Id
    ...    id=${entity_id}
    ...    context=${ngsild_test_suite_context}
    ...    accept=${CONTENT_TYPE_LD_JSON}
    ${ignored_attributes}=    Create List    @context
    Check Updated Resource Set To    ${entity_expectation_payload}    ${response.json()}    ${ignored_attributes}

Delete Initial Entities
    Delete Entity by Id Returning Response    ${entity_id}
