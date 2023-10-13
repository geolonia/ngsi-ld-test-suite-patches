*** Settings ***
Documentation       Check that you cannot create a context source registration that already exists

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Create New Context Source Registration
Suite Teardown      Delete Created Context Source Registrations


*** Variables ***
${registration_id_prefix}=      urn:ngsi-ld:Registration:
${filename}=                    csourceRegistrations/context-source-registration-simple-sample.jsonld


*** Test Cases ***
033_03_01 Create a context source registration that already exists
    [Documentation]    Check that you cannot create a context source registration that already exists
    [Tags]    csr-create    5_9_2
    ${response}=    Create Context Source Registration With Return    ${updated_payload}
    Check Response Status Code    409    ${response.status_code}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}


*** Keywords ***
Delete Created Context Source Registrations
    Delete Context Source Registration    ${registration_id}

Create New Context Source Registration
    ${registration_id}=    Generate Random Entity Id    ${registration_id_prefix}
    Set Suite Variable    ${registration_id}
    ${payload}=    Load JSON From File    ${EXECDIR}/data/${filename}
    ${updated_payload}=    Update Value To JSON    ${payload}    $..id    ${registration_id}
    ${response}=    Create Context Source Registration With Return    ${updated_payload}
    Check Response Status Code    201    ${response.status_code}
    Set Global Variable    ${updated_payload}
