*** Settings ***
Documentation       Check that you cannot update entity attributes with invalid/missing id or invalid request body

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Initialize Environment    ${filename}
Test Template       Update entity attributes with invalid entity fragments


*** Variables ***
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:
${filename}=                vehicle-speed-two-datasetid-sample.jsonld


*** Test Cases ***
011_04_01 Update entity attributes with invalid entity fragments
    vehicle-speed-two-datasetid-sample.jsonld    invalid-fragment.jsonld


*** Keywords ***
Update entity attributes with invalid entity fragments
    [Documentation]    Check that you cannot update an attribute if the entity fragment is invalid
    [Tags]    ea-update    5_6_2
    [Arguments]    ${filename}    ${fragment_filename}
    ${response}=    Update Entity Attributes
    ...    ${entity_id}
    ...    ${fragment_filename}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    400    ${response.status_code}
    Check Response Body Type When Using Session Request    ${response.json()}    ${ERROR_TYPE_INVALID_REQUEST}
    Check Response Body Title When Using Session Request    ${response.json()}
    [Teardown]    Delete Entity by Id Returning Response    ${entity_id}

Initialize Environment
    [Arguments]    ${filename}
    ${entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    Set Global Variable    ${entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
