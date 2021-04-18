*** Settings ***
Documentation     Check that you cannot query context source registrations, if neither Entity types nor Attribute names are provided, an error of type
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource

*** Test Case ***
Query Context Source Registrations Without Entity Types and Attribute Names
    [Documentation]    Check that you cannot query context source registrations, if neither Entity types nor Attribute names are provided, an error of type
    [Tags]    csr-query    5_10_2
    Query Context Source Registrations    context=${ngsild_test_suite_context}
    Check Response Status Code Set To    400
    Check Response Body Containing ProblemDetails Element Containing Type Element set to    ${response}    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}
