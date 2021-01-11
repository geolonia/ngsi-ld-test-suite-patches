*** Settings ***
Documentation   Check that you can append entity attributes
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Append Attributes

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:

*** Test Cases ***                    STATUS_CODE      OVERWRITE           FILENAME                                           FRAGMENT_FILENAME                                     EXPECTATION_FILENAME
001_01_Append entity attributes       204              ${EMPTY}            vehicle-datasetid-attributes-sample.jsonld         vehicle-fragment-datasetid-sample-01-02.jsonld        vehicle-attributes-sample-append-expectation-01.jsonld
001_02_Append entity attributes       207              noOverwrite         vehicle-datasetid-attributes-sample.jsonld         vehicle-fragment-datasetid-sample-01-02.jsonld        vehicle-attributes-sample-append-expectation-02.jsonld
001_03_Append entity attributes       204              ${EMPTY}            vehicle-datasetid-attributes-sample.jsonld         vehicle-fragment-datasetid-sample-03-04.jsonld        vehicle-attributes-sample-append-expectation-03-04.jsonld
001_04_Append entity attributes       204              noOverwrite         vehicle-datasetid-attributes-sample.jsonld         vehicle-fragment-datasetid-sample-03-04.jsonld        vehicle-attributes-sample-append-expectation-03-04.jsonld

*** Keywords ***
Append Attributes
    [Arguments]  ${status_code}    ${overwrite}    ${filename}    ${fragment_filename}    ${expectation_filename}
    [Documentation]  Check that you can append entity attributes
    [Tags]  mandatory  failing

    ${entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Append Entity Attributes    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}    ${overwrite}
    Check Response Status Code  ${status_code}    ${response['status']}
    Check Response Body Containing Entity element    ${expectation_filename}    ${entity_id}    ${response['body']}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}