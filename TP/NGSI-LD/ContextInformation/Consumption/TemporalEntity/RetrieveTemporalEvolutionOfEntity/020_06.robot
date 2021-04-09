*** Settings ***
Documentation   Check that you cannot retrieve the temporal evolution of an entity with an invalid id (invalid URI)
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Test Case ***
Retrieve the temporal evolution of an entity with an invalid id
    [Documentation]  Check that you cannot retrieve the temporal evolution of an entity with an invalid id (invalid URI)
    [Tags]   te-retrieve    5_7_3

    Retrieve Temporal Representation Of Entity   invalidUri

    Check Response Status Code Set To  400
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}
