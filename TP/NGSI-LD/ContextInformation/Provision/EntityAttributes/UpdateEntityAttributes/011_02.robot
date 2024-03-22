*** Settings ***
Documentation       Check that you cannot update entity attributes with invalid/missing id or invalid request body

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Initialize Environment
Test Teardown       Delete Entity
Test Template       Update Attributes


*** Variables ***
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:


*** Test Cases ***    ENTITY_INVALID_ID    FRAGMENT_FILENAME
011_02_01 Update an attribute if the Entity Id is not present
    ${EMPTY}    vehicle-speed-two-datasetid-01-fragment.jsonld
011_02_02 Update an attribute if the Entity Id is not a valid URI
    thisisaninvaliduri    vehicle-speed-two-datasetid-01-fragment.jsonld


*** Keywords ***
Update Attributes
    [Documentation]    Check that you cannot update entity attributes with invalid/missing id or invalid request body
    [Tags]    ea-update    5_6_2
    [Arguments]    ${entity_invalid_id}    ${fragment_filename}
    ${response}=    Update Entity Attributes    ${entity_invalid_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    400    ${response.status_code}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()}
    ...    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}

Initialize Environment
    ${entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    Set Test Variable    ${entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    vehicle-two-datasetid-attributes-sample.jsonld
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}

Delete Entity
    Delete Entity by Id    ${entity_id}
