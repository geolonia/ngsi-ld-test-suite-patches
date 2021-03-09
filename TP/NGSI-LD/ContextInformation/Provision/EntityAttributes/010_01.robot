*** Settings ***
Documentation   Check that you can append entity attributes
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Append Attributes

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${filename}=  vehicle-speed-two-datasetid-sample.jsonld

*** Test Cases ***                       STATUS_CODE      OVERWRITE           FRAGMENT_FILENAME                                         EXPECTATION_FILENAME
010_01_01_Append entity attributes       204              ${EMPTY}            vehicle-attribute-to-add-fragment.jsonld             ${EMPTY}
010_01_02_Append entity attributes       207              noOverwrite         vehicle-attribute-to-add-fragment.jsonld             add-attribute-expectation.jsonld
010_01_03_Append entity attributes       204              ${EMPTY}            vehicle-speed-different-datasetid-fragment.jsonld        ${EMPTY}
010_01_04_Append entity attributes       204              noOverwrite         vehicle-speed-different-datasetid-fragment.jsonld        ${EMPTY}

*** Keywords ***
Append Attributes
    [Arguments]  ${status_code}    ${overwrite}   ${fragment_filename}    ${expectation_filename}
    [Documentation]  Check that you can append entity attributes
    [Tags]  mandatory  

    ${entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Append Entity Attributes    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}    ${overwrite}
    Check Response Status Code  ${status_code}    ${response['status']}
    Run Keyword If    "${expectation_filename}"!="${EMPTY}"    Check Response Body Content    ${expectation_filename}    ${response['body']}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}