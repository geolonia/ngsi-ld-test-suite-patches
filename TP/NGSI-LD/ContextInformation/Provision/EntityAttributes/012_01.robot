*** Settings ***
Documentation   Check that you can perform a partial update on an entity attribute
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Update Attributes

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${filename}=  vehicle-datasetid-attributes-sample.jsonld
${attribute_id}=  speed
${status_code}=  204

*** Test Cases ***                                                                          FRAGMENT_FILENAME                                                    
012_01_01_Check that you can partially update an attribute                                     vehicle-fragment-empty-datasetid-sample.jsonld                       
012_01_02_Check that you can partially update an attribute by specifying the datasetId        vehicle-fragment-equal-datasetid-sample.jsonld                                                 

*** Keywords ***
Update Attributes
    [Arguments]  ${fragment_filename}
    [Documentation]  Check that you can perform a partial update on an entity attribute
    [Tags]  mandatory  failing

    ${entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Partial Update Entity Attributes    ${entity_id}    ${attribute_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  ${status_code}    ${response['status']}
    #TODO: check body response is empty

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}