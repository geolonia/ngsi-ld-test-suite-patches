*** Settings ***
Documentation       Check that you can append entity attributes

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision/ApiUtils.resource
# Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Template       Append Attributes With Params


*** Variables ***
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:
${filename}=                vehicle-speed-two-datasetid-sample.jsonld


*** Test Cases ***    STATUS_CODE    FRAGMENT_FILENAME    EXPECTATION_RESPONSE_BODY    EXPECTATION_FILENAME
010_04_01 Append entity attributes
    207    vehicle-attribute-to-add-fragment.jsonld    add-attribute-expectation.jsonld    vehicle-speed-appended-expectation.jsonld
010_04_02 Append entity attributes
    204    vehicle-speed-different-datasetid-fragment.jsonld    ${EMPTY}    vehicle-speed-different-datasetid-expectation.jsonld


*** Keywords ***
Append Attributes With Params
    [Documentation]    Check that you can append entity attributes
    [Tags]    ea-append    5_6_3
    [Arguments]    ${status_code}    ${fragment_filename}    ${expectation_response_body}    ${expectation_filename}
    ${entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    ${response}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Append Entity Attributes With Parameters
    ...    ${entity_id}
    ...    ${fragment_filename}
    ...    ${CONTENT_TYPE_LD_JSON}
    ...    noOverwrite
    Check Response Status Code    ${status_code}    ${response.status_code}
    # ignore the reason for the not updated attribute as this detail is up to each context broker implementation
    IF    "${expectation_response_body}"!="${EMPTY}"
        Check Response Body Content
        ...    ${expectation_response_body}
        ...    ${response.json()}
        ...    root\\['notUpdated'\\]\\[0\\]\\['reason'\\]
    END
    ${entity_expectation_payload}=    Load Test Sample    entities/expectations/${expectation_filename}    ${entity_id}
    ${response}=    Retrieve Entity by Id
    ...    id=${entity_id}
    ...    context=${ngsild_test_suite_context}
    ...    accept=${CONTENT_TYPE_LD_JSON}
    ${ignored_attributes}=    Create List    @context
    Check Updated Resource Set To    ${entity_expectation_payload}    ${response.json()}    ${ignored_attributes}
    [Teardown]    Delete Entity by Id Returning Response    ${entity_id}
