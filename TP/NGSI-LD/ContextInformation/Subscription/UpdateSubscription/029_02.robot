*** Settings ***
Documentation   Check that you cannot update a subscription: If the NGSI-LD System does not know about the target Subscription, because there is no existing Subscription whose id (URI) is equivalent, an error of type ResourceNotFound shall be raised
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${subscription_update_fragment_file_path}=   subscriptions/fragments/subscription-update-sample.json

*** Test Case ***
Update Unknown Subscription
    [Documentation]  Check that you cannot update a subscription: If the NGSI-LD System does not know about the target Subscription, because there is no existing Subscription whose id (URI) is equivalent, an error of type ResourceNotFound shall be raised
    [Tags]  mandatory

    Update Subscription   unknownSubscription     ${subscription_update_fragment_file_path}   ${CONTENT_TYPE_JSON}

    Check Response Status Code Set To  404
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_RESOURCE_NOT_FOUND}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}
