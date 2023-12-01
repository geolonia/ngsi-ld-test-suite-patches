*** Settings ***
Documentation       Check that you can update a context source registration by id

Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistration.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceDiscovery.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Initialize the Test Case
Test Teardown       Delete Updated Context Source Registration
Test Template       Update A Context Source


*** Variables ***
${registration_id_prefix}=      urn:ngsi-ld:Registration:


*** Test Cases ***    FILENAME    UPDATE_FILENAME
034_01_01 Update a context source registration by id
    [Tags]    csr-update    5_9_3
    context-source-registration-sample.jsonld    context-source-registration-with-expiration-sample.jsonld
034_01_02 Update a context source registration to never expire
    [Tags]    csr-update    5_9_3
    context-source-registration-with-expiration-sample.jsonld    context-source-registration-sample.jsonld


*** Keywords ***
Update A Context Source
    [Documentation]    Check that you can update a context source registration by id
    [Arguments]    ${filename}    ${update_filename}
    Set Global Variable    ${filename}
    ${fragment}=    Load JSON From File    ${EXECDIR}/data/csourceRegistrations/${update_filename}
    ${registration_update_fragment}=    Update Value To JSON    ${fragment}    $..id    ${registration_id}
    ${response}=    Update Context Source Registration With Return
    ...    ${registration_id}
    ...    ${registration_update_fragment}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    204    ${response.status_code}
    Check Retrieving Context Source Registration
    ...    registration_id=${registration_id}
    ...    context=${ngsild_test_suite_context}
    ...    accept=${CONTENT_TYPE_LD_JSON}
    ...    registration_payload=${registration_payload}

Delete Updated Context Source Registration
    Delete Context Source Registration    ${registration_id}

Initialize the Test Case
    ${registration_id}=    Generate Random Entity Id    ${registration_id_prefix}
    Set Test Variable    ${registration_id}
    # ${payload}=    Load JSON From File    ${EXECDIR}/data/csourceRegistrations/${filename}
    ${payload}=    Load JSON From File
    ...    ${EXECDIR}/data/csourceRegistrations/context-source-registration-sample.jsonld
    ${registration_payload}=    Update Value To JSON    ${payload}    $..id    ${registration_id}
    Set Global Variable    ${registration_payload}
    ${response}=    Create Context Source Registration With Return    ${registration_payload}
    Check Response Status Code    201    ${response.status_code}
