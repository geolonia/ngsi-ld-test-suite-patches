*** Settings ***
Documentation       Check that you cannot delete a subscription: If the subscription Id is not present or it is not a valid URI, then an error of type BadRequestData shall be raised

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationSubscription.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource

Test Template       Delete Subscription With Non present Or Invalid Id


*** Test Cases ***    id
032_01_01 NotPresentId
    [Tags]    sub-delete    5_8_5
    ${EMPTY}
032_01_02 InvalidId
    [Tags]    sub-delete    5_8_5
    InvalidUri


*** Keywords ***
Delete Subscription With Non present Or Invalid Id
    [Documentation]    Check that you cannot delete a subscription: If the subscription Id is not present or it is not a valid URI, then an error of type BadRequestData shall be raised
    [Arguments]    ${id}
    ${response}=    Delete Subscription    ${id}
    Check Response Status Code    400    ${response.status_code}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()}
    ...    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}
