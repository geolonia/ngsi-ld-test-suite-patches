*** Settings ***
Documentation       Check that appending an attribute whose value is NGSI-LD Null returns 400 BadRequestData

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource

Test Setup          Create Initial Entity
Test Teardown       Delete Initial Entity
Test Template       Append Attributes With Null Value


*** Variables ***
${filename}=    building-minimal.jsonld


*** Test Cases ***    FRAGMENT_FILENAME
010_12_01 AppendAttributeWithNullValue
    [Tags]    ea-append    5_6_3    since_v1.6.1
    ngsild-null/null-property.jsonld


*** Keywords ***
Append Attributes With Null Value
    [Documentation]    Check that appending an attribute whose value is NGSI-LD Null returns 400 BadRequestData
    [Arguments]    ${fragment_filename}
    ${response}=    Append Entity Attributes    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    400    ${response.status_code}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()}
    ...    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}

Create Initial Entity
    ${entity_id}=    Generate Random Vehicle Entity Id
    ${response}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    Set Suite Variable    ${entity_id}

Delete Initial Entity
    Delete Entity    ${entity_id}
