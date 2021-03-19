*** Settings ***
Documentation   Check that you cannot update a subcription: If the Subscription id is not present or it is not a valid URI, then an error of type BadRequestData shall be raised
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Update Subscription With Non present Or Invalid Id

*** Test Cases ***          id
NotPresentId                ${EMPTY}
InvalidId                   InvalidUri

*** Variable ***
${subscription_update_fragment_file_path}=   subscriptions/fragments/subscription-update-sample.json

*** Keywords ***
Update Subscription With Non present Or Invalid Id
    [Arguments]  ${id}
    [Documentation]  Check that you cannot update a subcription: If the Subscription id is not present or it is not a valid URI, then an error of type BadRequestData shall be raised
    [Tags]  mandatory

    Update Subscription   ${id}     ${subscription_update_fragment_file_path}   ${CONTENT_TYPE_JSON}

    Check Response Status Code Set To  400
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}
