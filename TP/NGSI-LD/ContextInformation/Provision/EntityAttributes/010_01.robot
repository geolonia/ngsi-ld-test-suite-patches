*** Settings ***
Documentation   Check that you can append entity attributes
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${filename}=  vehicle-speed-two-datasetid-sample.jsonld

*** Test Cases ***
010_01_01_Append entity attributes       
    Append Attributes Without Params  204    vehicle-attribute-to-add-fragment.jsonld
010_01_02_Append entity attributes
    Append Attributes With Params  207    vehicle-attribute-to-add-fragment.jsonld    add-attribute-expectation.jsonld
010_01_03_Append entity attributes
    Append Attributes Without Params  204    vehicle-speed-different-datasetid-fragment.jsonld
010_01_04_Append entity attributes
    Append Attributes With Params  204    vehicle-speed-different-datasetid-fragment.jsonld    ${EMPTY}

*** Keywords ***
Append Attributes Without Params
    [Arguments]  ${status_code}    ${fragment_filename}
    [Documentation]  Check that you can append entity attributes
    [Tags]  /entities/{entityId}/attrs/      5_6_3

    ${entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Append Entity Attributes    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  ${status_code}    ${response['status']}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}

Append Attributes With Params
    [Arguments]  ${status_code}    ${fragment_filename}    ${expectation_filename}
    [Documentation]  Check that you can append entity attributes
    [Tags]  /entities/{entityId}/attrs/      5_6_3

    ${entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Append Entity Attributes With Parameters    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}    noOverwrite
    Check Response Status Code  ${status_code}    ${response['status']}
    Run Keyword If    "${expectation_filename}"!="${EMPTY}"    Check Response Body Content    ${expectation_filename}    ${response['body']}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}