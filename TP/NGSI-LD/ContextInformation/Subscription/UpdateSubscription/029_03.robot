*** Settings ***
Documentation   Check that you cannot update a subcription: If the data types and restriction are not met by the Subscription Fragment, then an error of type BadRequestData shall be raised
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Suite Setup      Setup Initial Subscriptions
Suite Teardown      Delete Initial Subscriptions

*** Variable ***
${subscription_id_prefix}=  urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=   subscriptions/subscription-sample.jsonld
${subscription_update_fragment_file_path}=   subscriptions/fragments/subscription-invalid-update-sample.json

*** Test Case ***
Update Subscription With Invalid Fragment
    [Documentation]  Check that you cannot update a subcription: If the data types and restriction are not met by the Subscription Fragment, then an error of type BadRequestData shall be raised
    [Tags]  mandatory

    Update Subscription   ${subscription_id}     ${subscription_update_fragment_file_path}   ${CONTENT_TYPE_JSON}

    Check Response Status Code Set To  400
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}

*** Keywords ***
Setup Initial Subscriptions
    ${subscription_id}=     Generate Random Entity Id    ${subscription_id_prefix}

    Create Subscription  ${subscription_id}     ${subscription_payload_file_path}   ${CONTENT_TYPE_LD_JSON}

    Set Suite Variable  ${subscription_id}

Delete Initial Subscriptions
    Delete Subscription     ${subscription_id}
