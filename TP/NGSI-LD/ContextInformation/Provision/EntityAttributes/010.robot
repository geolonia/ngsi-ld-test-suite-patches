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
${attribute_id}=  'https://uri.fiware.org/ns/data-models#speed'

*** Test Cases ***                                                     DATASETID                                    DELETEALL 
010_01_delete an attribute with the id                                 ${EMPTY}                                     False  
010_02_delete an attribute with the datasetId                          urn:ngsi-ld:Property:gpsBxyz123-speed        False 
010_03_delete all target attribute instances with a datasetId          urn:ngsi-ld:Property:gpsBxyz123-speed        True   

*** Keywords ***
Delete Attributes
    [Arguments]  ${datasetId}    ${deleteAll}
    [Documentation]  Check that you can delete an attribute from an entity
    [Tags]  mandatory  failing

    ${entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}
    Query Entity    ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    ${response}=    Delete Entity Attributes    ${entity_id}    ${attribute_id}    ${CONTENT_TYPE_LD_JSON}    ${datasetId}    ${deleteAll}
    Check Response Status Code  ${status_code}    ${response['status']}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}