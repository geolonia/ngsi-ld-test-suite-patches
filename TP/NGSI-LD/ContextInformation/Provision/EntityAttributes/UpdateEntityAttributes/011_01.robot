*** Settings ***
Documentation       Check that one can update entity attributes

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Initialize Test
Test Teardown       Delete Initial Entities
Test Template       Update Attributes


*** Variables ***
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:
${filename}=                vehicle-two-datasetid-attributes-sample.jsonld


*** Test Cases ***    STATUS_CODE    FRAGMENT_FILENAME    EXPECTATION_RESPONSE_FILENAME    EXPECTATION_FILENAME
011_01_01 Check that one can update existing attributes with no datasetId
    204    vehicle-speed-two-datasetid-01-fragment.jsonld    ${EMPTY}    expectations/vehicle-update-attributes-expectation.jsonld
011_01_02 Check that one can update existing attributes with the datasetId
    204    vehicle-speed-two-datasetid-02-fragment.jsonld    ${EMPTY}    expectations/vehicle-update-datasetid-attributes-expectation.jsonld
011_01_03 Check that one can update only some attributes while unknown are ignored
    204    vehicle-speed-two-datasetid-03-fragment.jsonld    ${EMPTY}    expectations/vehicle-multi-attributes-expectation.jsonld


*** Keywords ***
Update Attributes
    [Documentation]    Check that one can update entity attributes
    [Tags]    ea-update    5_6_2
    [Arguments]
    ...    ${status_code}
    ...    ${fragment_filename}
    ...    ${expectation_resp_filename}
    ...    ${expectation_filename}
    ${response}=    Update Entity Attributes
    ...    ${entity_id}
    ...    ${fragment_filename}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    ${status_code}    ${response.status_code}
    IF    "${expectation_resp_filename}"!="${EMPTY}"
        Check Response Body Content
        ...    expectation_filename=${expectation_resp_filename}
        ...    response_body=${response.json()}
    END
    ${entity_expectation_payload}=    Load Test Sample    entities/${expectation_filename}    ${entity_id}
    ${response1}=    Retrieve Entity by Id
    ...    id=${entity_id}
    ...    context=${ngsild_test_suite_context}
    ...    accept=${CONTENT_TYPE_LD_JSON}
    ${ignored_attributes}=    Create List    @context
    Check Updated Resource Set To
    ...    updated_resource=${entity_expectation_payload}
    ...    response_body=${response1.json()}
    ...    ignored_keys=${ignored_attributes}

Delete Initial Entities
    Delete Entity by Id    ${entity_id}

Initialize Test
    ${entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    Set Test Variable    ${entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
