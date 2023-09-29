*** Settings ***
Documentation       Check that you can update a context source registration by id

Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceRegistration.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextSourceDiscovery.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Teardown       Delete Updated Context Source Registration
Test Template       Update Context Source


*** Variables ***
${registration_id_prefix}=      urn:ngsi-ld:Registration:


*** Test Cases ***    FILENAME    UPDATE_FILENAME
034_01_01 Update a context source registration by id
    [Tags]    csr-update    5_9_3
    context-source-registration-sample.jsonld    context-source-registration-with-expiration-sample.jsonld
034_01_02 Update a context source registration to never expire
    [Tags]    csr-update    5_9_3
    context-source-registration-with-expiration-sample.jsonld    context-source-registration-simple-sample.jsonld


*** Keywords ***
Update Context Source
    [Documentation]    Check that you can update a context source registration by id
    [Arguments]    ${filename}    ${update_filename}
    ${registration_id}=    Generate Random Entity Id    ${registration_id_prefix}
    Set Test Variable    ${registration_id}
    ${payload}=    Load JSON From File    ${EXECDIR}/data/csourceRegistrations/${filename}
    ${registration_payload}=    Update Value To JSON    ${payload}    $..id    ${registration_id}
    ${response}=    Create Context Source Registration With Return    ${registration_payload}
    Check Response Status Code    201    ${response.status_code}
    ${fragment}=    Load JSON From File    ${EXECDIR}/data/csourceRegistrations/${update_filename}
    ${registration_update_fragment}=    Update Value To JSON    ${fragment}    $..id    ${registration_id}
    ${response}=    Update Context Source Registration With Return
    ...    ${registration_id}
    ...    ${registration_update_fragment}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    204    ${response.status_code}
    ${response}=    Retrieve Context Source Registration
    ...    ${registration_id}
    ...    context=${ngsild_test_suite_context}
    ...    accept=${CONTENT_TYPE_LD_JSON}
    ${ignored_attributes}=    Create List    ${status_regex_expr}    @context
    Check Updated Resource Set To    ${registration_payload}    ${response.json()}    ${ignored_attributes}

Delete Updated Context Source Registration
    Delete Context Source Registration    ${registration_id}
