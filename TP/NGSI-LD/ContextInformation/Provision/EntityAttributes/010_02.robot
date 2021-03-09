*** Settings ***
Documentation   Check that you cannot append entity attributes with invalid/missing id or invalid request body
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${filename}=  vehicle-speed-two-datasetid-sample.jsonld
${fragment_filename}=  vehicle-attribute-to-add-fragment.jsonld
${status_code}=  400
${invalid_fragment_filename}=  invalid-fragment.jsonld

*** Test Cases ***
#010_02_01_Append entity attributes if the entity Id is not present                
#  Append Attributes  ${EMPTY}               
#010_02_02_Append entity attributes if the Entity Id is not a valid URI            
#  Append Attributes  thisisaninvaliduri
010_02_03_Append entity attributes with invalid entity fragments
  Append entity attributes with invalid entity fragments

*** Keywords ***
Append Attributes
    [Arguments]  ${entity_invalid_id}
    [Documentation]  Check that you cannot append entity attributes with invalid/missing id or invalid request body
    [Tags]  mandatory

    ${entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Append Entity Attributes    ${entity_invalid_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}    ${EMPTY}
    Check Response Status Code  ${status_code}    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}

Append entity attributes with invalid entity fragments
    [Documentation]  Check that you cannot append entity attributes with invalid entity fragments
    [Tags]  mandatory

    ${entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Append Entity Attributes Using Session    ${entity_id}    ${invalid_fragment_filename}    ${CONTENT_TYPE_LD_JSON}    ${EMPTY}
    Check Response Status Code  <Response [400]>    ${response}
    Check Response Body Type When Using Session Request      ${response.json()}     ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Title When Using Session Request    ${response.json()}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}