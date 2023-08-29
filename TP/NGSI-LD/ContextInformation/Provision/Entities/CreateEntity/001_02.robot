*** Settings ***
Documentation       Check that you cannot create an entity with an invalid request

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision/ApiUtils.resource
# Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource

Test Template       Create Entity With Invalid Request Scenarios


*** Test Cases ***    FILENAME    ERROR_TYPE
001_02_01_InvalidJson
    invalid-json-sample.jsonld    ${ERROR_TYPE_INVALID_REQUEST}
001_02_02_EmptyJson
    empty-sample.jsonld    ${ERROR_TYPE_INVALID_REQUEST}
001_02_03_EntityWithNoContext
    building-minimal-without-context-sample.jsonld    ${ERROR_TYPE_BAD_REQUEST_DATA}


*** Keywords ***
Create Entity With Invalid Request Scenarios
    [Documentation]    Check that you cannot create an entity with an invalid request
    [Tags]    e-create    5_6_1
    [Arguments]    ${filename}    ${error_type}
    ${response}=    Request Entity From File    ${filename}
    Check Response Status Code    400    ${response.status_code}
    Check RL Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()}
    ...    ${error_type}
    Check RL Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}
