*** Settings ***
Documentation       Check that you cannot retrieve the temporal evolution of a non-existing entity

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource


*** Test Cases ***
020_07_01 Retrieve the temporal evolution of a non-existing entity
    [Documentation]    Check that you cannot retrieve the temporal evolution of a non-existing entity
    [Tags]    te-retrieve    5_7_3
    ${response}=    Retrieve Temporal Representation Of Entity    urn:ngsi-ld:Vehicle:unknowEntity
    Check Response Status Code    404    ${response.status_code}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()}
    ...    ${ERROR_TYPE_RESOURCE_NOT_FOUND}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}
