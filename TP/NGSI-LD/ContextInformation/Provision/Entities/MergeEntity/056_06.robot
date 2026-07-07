*** Settings ***
Documentation       Check that a Merge Entity operation setting an NGSI-LD Null datasetId returns 400 BadRequestData

Resource            ${EXECDIR}/resources/ApiUtils/Common.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource

Test Setup          Setup Initial Entity
Test Teardown       Delete Initial Entity
Test Template       Merge Entity With Null Reserved Field Scenarios


*** Variables ***
${entity_payload_filename}=     building-simple-attributes.jsonld


*** Test Cases ***    FILENAME
056_06_01 MergeEntitySettingDatasetIdToNull
    [Tags]    e-merge    5_6_17    since_v1.6.1
    fragmentEntities/ngsild-null/building-null-datasetid-fragment.jsonld


*** Keywords ***
Merge Entity With Null Reserved Field Scenarios
    [Documentation]    Check that a Merge Entity operation setting an NGSI-LD Null datasetId returns 400 BadRequestData
    [Arguments]    ${filename}
    ${response}=    Merge Entity
    ...    entity_id=${entity_id}
    ...    entity_filename=${filename}
    ...    content_type=${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    400    ${response.status_code}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()}
    ...    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}

Setup Initial Entity
    ${entity_id}=    Generate Random Building Entity Id
    ${response}=    Create Entity    ${entity_payload_filename}    ${entity_id}
    Set Test Variable    ${entity_id}
    Check Response Status Code    201    ${response.status_code}

Delete Initial Entity
    Delete Entity    ${entity_id}
