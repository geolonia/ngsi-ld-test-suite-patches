*** Settings ***
Documentation       Check that you cannot retrieve a Context Source Registration, if the NGSI-LD endpoint does not know about the target context source registration, because there is no existing context source registration whose id (URI) is equivalent

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource


*** Test Cases ***
Retrieve Unknown Context Source Registration
    [Documentation]    Check that you cannot retrieve a Context Source Registration, if the NGSI-LD endpoint does not know about the target context source registration, because there is no existing context source registration whose id (URI) is equivalent
    [Tags]    csr-retrieve    5_10_1
    ${response}=    Retrieve Context Source Registration    urn:ngsi-ld:ContextSourceRegistration:unknowRegistration
    Check Response Status Code    404    ${response.status_code}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()}
    ...    ${ERROR_TYPE_RESOURCE_NOT_FOUND}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}
