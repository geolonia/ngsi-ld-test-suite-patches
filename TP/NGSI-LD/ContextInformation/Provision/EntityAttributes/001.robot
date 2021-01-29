*** Settings ***
Documentation   Check that you can append entity attributes
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Append Attributes

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${filename}=  vehicle-datasetid-attributes-sample.jsonld

*** Test Cases ***                    STATUS_CODE      OVERWRITE           FRAGMENT_FILENAME                                         EXPECTATION_FILENAME
001_01_Append entity attributes       204              ${EMPTY}            vehicle-fragment-same-datasetid-sample.jsonld             ${EMPTY}
001_02_Append entity attributes       207              noOverwrite         vehicle-fragment-same-datasetid-sample.jsonld             vehicle-attributes-sample-append-expectation-02.jsonld
001_03_Append entity attributes       204              ${EMPTY}            vehicle-fragment-different-datasetid-sample.jsonld        ${EMPTY}
001_04_Append entity attributes       204              noOverwrite         vehicle-fragment-different-datasetid-sample.jsonld        ${EMPTY}

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