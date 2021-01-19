*** Settings ***
Documentation   Check that you cannot append entity attributes with invalid/missing id or invalid request body
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Append Attributes

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${filename}=  vehicle-datasetid-attributes-sample.jsonld
${fragment_filename}=  vehicle-fragment-same-datasetid-sample.jsonld
${status_code}=  400

*** Test Cases ***                                                             ENTITY_INVALID_ID      
002_01_Append entity attributes if the entity Id is not present                ${EMPTY}               
002_02_Append entity attributes if the Entity Id is not a valid URI            thisisaninvaliduri

*** Keywords ***
Append Attributes
    [Arguments]  ${entity_invalid_id}
    [Documentation]  Check that you cannot append entity attributes with invalid/missing id or invalid request body
    [Tags]  mandatory  failing

    ${entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Append Entity Attributes    ${entity_invalid_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}    ${EMPTY}
    Check Response Status Code  ${status_code}    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}