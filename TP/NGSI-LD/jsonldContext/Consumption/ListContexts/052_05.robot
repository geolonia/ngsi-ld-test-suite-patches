*** Settings ***
Documentation       Check that you can list all the @context available in the broker with several add @contexts with details equal to true

Resource            ${EXECDIR}/resources/ApiUtils/jsonldContext.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/HttpUtils.resource

Test Setup          Create Initial set of @contexts
Test Teardown       Delete Initial @contexts
Test Template       List @contexts with several previous created @context


*** Variables ***
${first_filename}=      @context-minimal-valid.json
${second_filename}=     @context-minimal-second-valid.json
${third_filename}=      @context-minimal-third-valid.json
${reason_200}=          OK
${reason_204}=          No Content


*** Test Cases ***    DETAILS    KIND    COUNT
052_05_01 List @contexts with details set to true and no kind and with previously several add @contexts
    [Tags]    ctx-list    5_13_3    since_v1.5.1
    true    ${EMPTY}    4
052_05_02 List @contexts with details set to true and kind set to hosted and with previously several add @contexts
    [Tags]    ctx-list    5_13_3    since_v1.5.1
    true    Hosted    3
052_05_03 List @contexts with details set to true and kind set to cached abd with previously several add @contexts
    [Tags]    ctx-list    5_13_3    since_v1.5.1
    true    Cached    1
052_05_04 List @contexts with details set to true and kind set to implicitlycreated and with previously several add @contexts
    [Tags]    ctx-list    5_13_3    since_v1.5.1
    true    ImplicitlyCreated    0


*** Keywords ***
Create Initial set of @contexts
    ${response}=    Add a new @context    ${first_filename}
    Check Response Status Code    201    ${response.status_code}
    ${first_uri}=    Fetch Id From Response Location Header    ${response.headers}
    Set Suite Variable    ${first_uri}

    ${response}=    Add a new @context    ${second_filename}
    Check Response Status Code    201    ${response.status_code}
    ${second_uri}=    Fetch Id From Response Location Header    ${response.headers}
    Set Suite Variable    ${second_uri}

    ${response}=    Add a new @context    ${third_filename}
    Check Response Status Code    201    ${response.status_code}
    ${third_uri}=    Fetch Id From Response Location Header    ${response.headers}
    Set Suite Variable    ${third_uri}

    @{uris}=    Create List
    Append To List    ${uris}    ${first_uri}
    Append To List    ${uris}    ${second_uri}
    Append To List    ${uris}    ${third_uri}
    Set Suite Variable    ${uris}

List @contexts with several previous created @context
    [Documentation]    Check that you can list @contexts
    [Arguments]    ${details}    ${kind}    ${count}

    ${response}=    List @contexts    ${details}    ${kind}

    Check Response Status Code    200    ${response.status_code}
    Check Response Reason set to    ${response.reason}    ${reason_200}

    # We need to check the list of responses
    Check Context Response Body Containing a JSONObject with details of the @contexts
    ...    response=${response.json()}
    ...    expected_length=${count}
    ...    list_contexts=${uris}

Delete Initial @contexts
    FOR    ${uri}    IN    @{uris}
        Log    URI: ${uri}
        Delete a @context    ${uri}
    END
