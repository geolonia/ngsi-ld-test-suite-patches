*** Settings ***
Documentation   Check that you cannot update entity attributes with invalid/missing id or invalid request body
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Update Attributes

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${filename}=  vehicle-two-datasetid-attributes-sample.jsonld
${fragment_filename}=  vehicle-two-datasetid-attributes-sample-01.jsonld

*** Test Cases ***                                                             STATUS_CODE     ENTITY_INVALID_ID      
005_01_Update an attribute if the Entity Id is not present                     400             ${EMPTY}               
005_02_Update an attribute if the Entity Id is not a valid URI                 400             thisisaninvaliduri

*** Keywords ***
Update Attributes
    [Arguments]  ${status_code}    ${entity_invalid_id}
    [Documentation]  Check that you cannot update entity attributes with invalid/missing id or invalid request body
    [Tags]  mandatory  failing

    ${entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Update Entity Attributes    ${entity_invalid_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  ${status_code}    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}