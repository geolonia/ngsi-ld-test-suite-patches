*** Settings ***
Documentation   Check that you cannot update entity attributes with invalid/missing id or invalid request body
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:

*** Test Cases ***
011_02_01_Update an attribute if the Entity Id is not present                     
  Update Attributes  ${EMPTY}    vehicle-two-datasetid-attributes-sample.jsonld    vehicle-speed-two-datasetid-01-fragment.jsonld
011_02_02_Update an attribute if the Entity Id is not a valid URI                 
  Update Attributes  thisisaninvaliduri    vehicle-two-datasetid-attributes-sample.jsonld    vehicle-speed-two-datasetid-01-fragment.jsonld
011_02_03_Update entity attributes with invalid entity fragments
  Update entity attributes with invalid entity fragments  vehicle-speed-two-datasetid-sample.jsonld    invalid-fragment.jsonld

*** Keywords ***
Update Attributes
    [Arguments]  ${entity_invalid_id}    ${filename}    ${fragment_filename}
    [Documentation]  Check that you cannot update entity attributes with invalid/missing id or invalid request body
    [Tags]  ea-update    5_6_2

    ${entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Update Entity Attributes    ${entity_invalid_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  400    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}

Update entity attributes with invalid entity fragments
    [Arguments]  ${filename}    ${fragment_filename}
    [Documentation]  Check that you cannot update an attribute if the entity fragment is invalid
    [Tags]  ea-update    5_6_2

    ${entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    Update Entity Attributes Using Session    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}    ${EMPTY}
    Check RL Response Status Code Set To  400
    Check Response Body Type When Using Session Request      ${response.json()}     ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Title When Using Session Request    ${response.json()}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}