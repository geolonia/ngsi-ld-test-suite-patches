*** Settings ***
Documentation     Check that you cannot query context source registrations, if the list of Entity identifiers includes a URI which it is not valid, or the query, geo-query or temporal query are not syntactically valid
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Test Template     Query Context Source Registration With Invalid Query Param

*** Test Cases ***    QUERY_PARAM_NAME    QUERY_PARAM_VALUE
Invalid URI           id                  invalidUri
                      [Tags]              csr-query            5_10_2

Invalid Query         q                   invalidQuery
                      [Tags]              csr-query            5_10_2

Invalid GeoQuery      georel              within
                      [Tags]              csr-query            5_10_2

Invalid Temporal Query
                      timerel             before
                      [Tags]              csr-query            5_10_2

*** Keywords ***
Query Context Source Registration With Invalid Query Param
    [Arguments]    ${query_param_name}    ${query_param_value}
    [Documentation]    Check that you cannot query context source registrations, if the list of Entity identifiers includes a URI which it is not valid, or the query, geo-query or temporal query are not syntactically valid
    Query Context Source Registrations    context=${ngsild_test_suite_context}    ${query_param_name}=${query_param_value}
    Check Response Status Code Set To    400
    Check Response Body Containing ProblemDetails Element Containing Type Element set to    ${response}    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}
