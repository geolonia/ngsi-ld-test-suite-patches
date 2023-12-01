*** Settings ***
Documentation       Check that you cannot append entity attributes with invalid/missing id or invalid request body

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource


*** Variables ***
${vehicle_id_prefix}=               urn:ngsi-ld:Vehicle:
${filename}=                        vehicle-speed-two-datasetid-sample.jsonld
${fragment_filename}=               vehicle-attribute-to-add-fragment.jsonld
${status_code}=                     400
${invalid_fragment_filename}=       invalid-fragment.jsonld


*** Test Cases ***
010_05_01 Append entity attributes with invalid entity fragments
    [Documentation]    Check that you cannot append entity attributes with invalid entity fragments
    [Tags]    ea-append    5_6_3
    ${entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    ${response}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Append Entity Attributes
    ...    ${entity_id}
    ...    ${invalid_fragment_filename}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    ${status_code}    ${response.status_code}
    Check Response Body Type When Using Session Request    ${response.json()}    ${ERROR_TYPE_INVALID_REQUEST}
    Check Response Body Title When Using Session Request    ${response.json()}
    [Teardown]    Delete Entity by Id Returning Response    ${entity_id}
