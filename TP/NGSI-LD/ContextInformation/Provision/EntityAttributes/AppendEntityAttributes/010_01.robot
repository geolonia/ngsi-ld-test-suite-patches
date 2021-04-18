*** Settings ***
Documentation     Check that you can append entity attributes
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${vehicle_id_prefix}=    urn:ngsi-ld:Vehicle:
${filename}=      vehicle-speed-two-datasetid-sample.jsonld

*** Test Cases ***
010_01_01_Append entity attributes
    Append Attributes Without Params    204    vehicle-new-attribute-fragment.jsonld    vehicle-speed-appended-expectation.jsonld

010_01_02_Append entity attributes
    Append Attributes With Params    207    vehicle-attribute-to-add-fragment.jsonld    add-attribute-expectation.jsonld    vehicle-speed-appended-expectation.jsonld

010_01_03_Append entity attributes
    Append Attributes Without Params    204    vehicle-speed-different-datasetid-fragment.jsonld    vehicle-speed-different-datasetid-expectation.jsonld

010_01_04_Append entity attributes
    Append Attributes With Params    204    vehicle-speed-different-datasetid-fragment.jsonld    ${EMPTY}    vehicle-speed-different-datasetid-expectation.jsonld

*** Keywords ***
Append Attributes Without Params
    [Arguments]    ${status_code}    ${fragment_filename}    ${expectation_filename}
    [Documentation]    Check that you can append entity attributes
    [Tags]    ea-append    5_6_3
    ${entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type    ${filename}    ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response['status']}
    ${response}=    Append Entity Attributes    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    ${status_code}    ${response['status']}
    ${entity_expectation_payload}=    Load Test Sample    entities/expectations/${expectation_filename}    ${entity_id}
    Retrieve Entity by Id    ${entity_id}    context=${ngsild_test_suite_context}    accept=${CONTENT_TYPE_LD_JSON}
    Check Updated Resource Set To    ${entity_expectation_payload}
    [Teardown]    Delete Entity by Id Returning Response    ${entity_id}

Append Attributes With Params
    [Arguments]    ${status_code}    ${fragment_filename}    ${expectation_response_body}    ${expectation_filename}
    [Documentation]    Check that you can append entity attributes
    [Tags]    ea-append    5_6_3
    ${entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type    ${filename}    ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response['status']}
    ${response}=    Append Entity Attributes With Parameters    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}    noOverwrite
    Check Response Status Code    ${status_code}    ${response['status']}
    # ignore the reason for the not updated attribute as this detail is up to each context broker implementation
    Run Keyword If    "${expectation_response_body}"!="${EMPTY}"    Check Response Body Content    ${expectation_response_body}    ${response['body']}    root\\['notUpdated'\\]\\[0\\]\\['reason'\\]
    ${entity_expectation_payload}=    Load Test Sample    entities/expectations/${expectation_filename}    ${entity_id}
    Retrieve Entity by Id    ${entity_id}    context=${ngsild_test_suite_context}    accept=${CONTENT_TYPE_LD_JSON}
    ${ignored_attributes}=    Create List    @context
    Check Updated Resource Set To    ${entity_expectation_payload}    ${ignored_attributes}
    [Teardown]    Delete Entity by Id Returning Response    ${entity_id}
