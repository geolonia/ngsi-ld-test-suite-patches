*** Settings ***
Documentation       Check that you can delete a previous created cached @context without reload param

Resource            ${EXECDIR}/resources/ApiUtils/jsonldContext.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/HttpUtils.resource

Test Setup          Create Initial cached @context
Test Teardown       Delete Initial @context


*** Variables ***
${filename}=        @context-cached-one-valid.json
${reason_204}=      No Content


*** Test Cases ***
051_03_01 Delete a @context whose kind is cached without reload param
    [Documentation]    Check that you can delete a cached @context
    [Tags]    ctx-serve    5_13_5    since_v1.5.1

    ${response}=    Delete a @context    ${contextId}

    Check Response Status Code    204    ${response.status_code}
    Check Response Reason set to    ${response.reason}    ${reason_204}
    Check Response Does Not Contain Body    ${response}


*** Keywords ***
Create Initial cached @context
    ${entity_payload}=    Load JSON From File    ${EXECDIR}/data/jsonldContext/${filename}
    ${contextId}=    Get From Dictionary    ${entity_payload}    @context
    ${contextId}=    Get From List    ${contextId}    0

    ${response}=    Add a new @context    ${filename}
    Check Response Status Code    201    ${response.status_code}
    ${uri}=    Fetch Id From Response Location Header    ${response.headers}

    ${response}=    Serve a @context    ${contextId}    true
    Check Response Kind set to    ${response.json()}    Cached

    Set Global Variable    ${contextId}

Delete Initial @context
    ${response}=    List @contexts    true    ${EMPTY}
    # We need to extract all the contexts except the core context and delete them
    FOR    ${item}    IN    @{response.json()}
        ${uri}=    Get From Dictionary    ${item}    URL
        IF    '${uri}'=='${core_context}'
            Log    WARNING, Trying to delete the Core Context
        ELSE
            Delete a @context    ${uri}
        END
    END
