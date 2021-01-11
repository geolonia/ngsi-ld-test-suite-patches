*** Settings ***
Documentation   Check that you can update entity attributes
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Update Attributes

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:

*** Test Cases ***                                                                STATUS_CODE               FILENAME                                               FRAGMENT_FILENAME                                        EXPECTATION_FILENAME
004_01_Check that you can update existing attributes with no datasetId            204                       vehicle-two-datasetid-attributes-sample.jsonld         vehicle-two-datasetid-attributes-sample-01.jsonld        vehicle-two-datasetid-attributes-sample-expectation-01.jsonld
004_02_Check that you can update existing attributes with the datasetId           204                       vehicle-two-datasetid-attributes-sample.jsonld         vehicle-two-datasetid-attributes-sample-02.jsonld        vehicle-two-datasetid-attributes-sample-expectation-01.jsonld
004_03_Check that you can update only some attributes while others failed         207                       vehicle-two-datasetid-attributes-sample.jsonld         vehicle-two-datasetid-attributes-sample-03.jsonld        vehicle-two-datasetid-attributes-sample-expectation-03.jsonld
004_04_Check that you cannot change the type of the attribute                     204                       vehicle-two-datasetid-attributes-sample.jsonld         vehicle-two-datasetid-attributes-sample-04.jsonld        vehicle-two-datasetid-attributes-sample-expectation-04.jsonld

*** Keywords ***
Update Attributes
    [Arguments]  ${status_code}    ${filename}    ${fragment_filename}    ${expectation_filename}
    [Documentation]  Check that you can update entity attributes
    [Tags]  mandatory  failing

    ${entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Update Entity Attributes    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  ${status_code}    ${response['status']}
    Check Response Body Content    ${expectation_filename}    ${response['body']}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}