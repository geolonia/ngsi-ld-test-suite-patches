*** Settings ***
Documentation   Check that you can update entity attributes
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Update Attributes

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${filename}=  vehicle-two-datasetid-attributes-sample.jsonld

*** Test Cases ***                                                                   STATUS_CODE               FRAGMENT_FILENAME                                     EXPECTATION_RESPONSE_FILENAME                        EXPECTATION_FILENAME
011_01_01_Check that you can update existing attributes with no datasetId            204                       vehicle-speed-two-datasetid-01-fragment.jsonld        ${EMPTY}                                             expectations/vehicle-update-attributes-expectation.jsonld
011_01_02_Check that you can update existing attributes with the datasetId           204                       vehicle-speed-two-datasetid-02-fragment.jsonld        ${EMPTY}                                             expectations/vehicle-update-datasetid-attributes-expectation.jsonld
011_01_03_Check that you can update only some attributes while others failed         207                       vehicle-speed-two-datasetid-03-fragment.jsonld        vehicle-speed-datasetid-expectation.jsonld           expectations/vehicle-multi-attributes-expectation.jsonld

*** Keywords ***
Update Attributes
    [Arguments]  ${status_code}    ${fragment_filename}    ${expectation_response_filename}    ${expectation_filename}
    [Documentation]  Check that you can update entity attributes
    [Tags]  /entities/{entityId}/attrs/      5_6_2

    ${entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Update Entity Attributes    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  ${status_code}    ${response['status']}
    Run Keyword If    "${expectation_response_filename}"!="${EMPTY}"    Check Response Body Content    ${expectation_response_filename}    ${response['body']}

    ${entity_expectation_payload}=    Load Test Sample   entities/${expectation_filename}    ${entity_id}
    Retrieve Entity by Id   ${entity_id}   context=${ngsild_test_suite_context}   accept=${CONTENT_TYPE_LD_JSON}
    ${ignored_attributes}=  Create List    ${status_regex_expr}    @context
    Check Updated Resource Set To     ${entity_expectation_payload}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}