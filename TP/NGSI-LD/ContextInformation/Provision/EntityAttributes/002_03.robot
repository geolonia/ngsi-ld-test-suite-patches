*** Settings ***
Documentation   Check that you cannot append entity attributes with invalid entity fragments
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${filename}=  vehicle-datasetid-attributes-sample.jsonld
${fragment_filename}=  invalid-vehicle-fragment-datasetid-sample.jsonld

*** Test Cases ***              
Append entity attributes with invalid entity fragments
    [Documentation]  Check that you cannot append entity attributes with invalid entity fragments
    [Tags]  mandatory  failing

    ${entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Append Entity Attributes Using Session    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}    ${EMPTY}
    Check Response Status Code  400    ${response['status']}
    #Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_BAD_REQUEST_DATA}
    #Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}