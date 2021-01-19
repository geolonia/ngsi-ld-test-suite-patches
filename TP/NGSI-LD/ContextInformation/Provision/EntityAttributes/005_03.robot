*** Settings ***
Documentation   Check that you cannot update an attribute if the entity fragment is invalid
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${filename}=  vehicle-datasetid-attributes-sample.jsonld
${fragment_filename}=  invalid-vehicle-fragment-datasetid-sample.jsonld

*** Test Cases ***              
Update entity attributes with invalid entity fragments
    [Documentation]  Check that you cannot update an attribute if the entity fragment is invalid
    [Tags]  mandatory  failing

    ${entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Update Entity Attributes Using Session    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}    ${EMPTY}
    Check Response Status Code  <Response [400]>    ${response}
    Check Response Body Type When Using Session Request      ${response.json()}     ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Title When Using Session Request    ${response.json()}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}