*** Settings ***
Documentation       Check that replacing an entity with a payload containing an attribute whose value is NGSI-LD Null returns 400 BadRequestData

Resource            ${EXECDIR}/resources/ApiUtils/Common.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource

Test Setup          Setup Initial Entity
Test Teardown       Delete Initial Entity
Test Template       Replace Entity With Null Value Scenarios


*** Variables ***
${entity_filename}=     building-simple-attributes.jsonld


*** Test Cases ***    REPLACEMENT_FILENAME
054_04_01 ReplaceEntityWithNullValueAttribute
    [Tags]    e-replace    5_6_18    since_v1.6.1
    fragmentEntities/ngsild-null/building-null-value-property.jsonld


*** Keywords ***
Replace Entity With Null Value Scenarios
    [Documentation]    Check that replacing an entity with a payload containing an attribute whose value is NGSI-LD Null returns 400 BadRequestData
    [Arguments]    ${replacement_filename}
    ${entity}=    Load Entity
    ...    entity_file_name=${replacement_filename}
    ...    entity_id=${entity_id}
    ${response}=    Replace Entity Selecting Content Type
    ...    entity_id=${entity_id}
    ...    entity_fragment=${entity}
    ...    content_type=${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    400    ${response.status_code}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()}
    ...    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}

Setup Initial Entity
    ${entity_id}=    Generate Random Building Entity Id
    Set Test Variable    ${entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${entity_filename}
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}

Delete Initial Entity
    Delete Entity    ${entity_id}
