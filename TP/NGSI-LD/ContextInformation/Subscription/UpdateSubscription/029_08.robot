*** Settings ***
Documentation     Check that you can update a subcription: If isActive is equal to true or null and expiresAt is null or corresponds to a DateTime in the future, then status shall be updated to "active"
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Test Template     Activate Paused Subscription With isActive And ExpiresAt Members
Suite Setup       Setup Initial Subscriptions
Suite Teardown    Delete Initial Subscriptions

*** Test Cases ***    SUBSCRIPTION_UPDATE_FRAGMENT_FILE_PATH
ActiveTrueExpiresAtNull
                      subscriptions/fragments/subscription-isActive-expiresAt-null-update-sample.json
                      [Tags]                                                                                  sub-update    5_8_2

ActiveTrueExpiresAt
                      subscriptions/fragments/subscription-isActive-expiresAt-update-sample.json
                      [Tags]                                                                                  sub-update    5_8_2

ActiveNullExpiresAtNull
                      subscriptions/fragments/subscription-isActive-null-expiresAt-null-update-sample.json
                      [Tags]                                                                                  sub-update    5_8_2

ActiveNullExpiresAt
                      subscriptions/fragments/subscription-isActive-null-expiresAt-update-sample.json
                      [Tags]                                                                                  sub-update    5_8_2

*** Variable ***
${subscription_id_prefix}=    urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=    subscriptions/subscription-inactive-sample.jsonld

*** Keywords ***
Activate Paused Subscription With isActive And ExpiresAt Members
    [Arguments]    ${subscription_update_fragment_file_path}
    [Documentation]    Check that you can update a subcription: If isActive is equal to true or null and expiresAt is null or corresponds to a DateTime in the future, then status shall be updated to "active"
    Update Subscription    ${subscription_id}    ${subscription_update_fragment_file_path}    ${CONTENT_TYPE_JSON}
    Check Response Status Code Set To    204
    Retrieve Subscription    ${subscription_id}
    Check Response Body Containing an Attribute set to    status    active

Setup Initial Subscriptions
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    Create Subscription    ${subscription_id}    ${subscription_payload_file_path}    ${CONTENT_TYPE_LD_JSON}
    Set Suite Variable    ${subscription_id}

Delete Initial Subscriptions
    Delete Subscription    ${subscription_id}
