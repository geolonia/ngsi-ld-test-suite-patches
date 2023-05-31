*** Settings ***
Documentation       Check that you can perform a partial update on an entity attribute

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Template       Update Attributes


*** Variables ***
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:
${filename}=                vehicle-speed-two-datasetid-sample.jsonld
${status_code}=             204


*** Test Cases ***    FRAGMENT_FILENAME    ATTRIBUTE_ID    EXPECTATION_FILENAME
012_01_01_Check that you can partially update an attribute
    vehicle-isparked-fragment.jsonld    isParked    vehicle-isparked-update-expectation.jsonld
012_01_02_Check that you can partially update an attribute by specifying the datasetId
    vehicle-speed-equal-datasetid-fragment.jsonld    speed    vehicle-update-speed-expectation.jsonld


*** Keywords ***
Update Attributes
    [Documentation]    Check that you can perform a partial update on an entity attribute
    [Tags]    ea-partial-update    5_6_4
    [Arguments]    ${fragment_filename}    ${attribute_id}    ${expectation_filename}
    ${entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response['status']}
    ${response}=    Partial Update Entity Attributes
    ...    ${entity_id}
    ...    ${attribute_id}
    ...    ${fragment_filename}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    ${status_code}    ${response['status']}
    ${entity_expectation_payload}=    Load Test Sample    entities/expectations/${expectation_filename}    ${entity_id}
    Retrieve Entity by Id    ${entity_id}    context=${ngsild_test_suite_context}    accept=${CONTENT_TYPE_LD_JSON}
    ${ignored_attributes}=    Create List    @context
    Check Updated Resource Set To    ${entity_expectation_payload}    ${ignored_attributes}
    [Teardown]    Delete Entity by Id Returning Response    ${entity_id}
