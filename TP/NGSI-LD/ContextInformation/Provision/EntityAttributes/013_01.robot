*** Settings ***
Documentation   Check that you can delete an attribute from an entity
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Delete Attributes

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${status_code}=  204
${filename}=  vehicle-two-datasetid-attributes-sample.jsonld
${attribute_id}=  speed

*** Test Cases ***                                                        DATASETID                                   DELETEALL 
013_01_01_delete an attribute with the id                                 ${EMPTY}                                    false  
013_01_02_delete an attribute with the datasetId                          urn:ngsi-ld:Property:gpsBxyz123-speed       false 
013_01_03_delete all target attribute instances with a datasetId          urn:ngsi-ld:Property:gpsBxyz123-speed       true   

*** Keywords ***
Delete Attributes
    [Arguments]  ${datasetId}    ${deleteAll}
    [Documentation]  Check that you can delete an attribute from an entity
    [Tags]  mandatory

    ${entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Delete Entity Attributes    ${entity_id}    ${attribute_id}    ${datasetId}    ${deleteAll}
    Check Response Status Code  ${status_code}    ${response['status']}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}