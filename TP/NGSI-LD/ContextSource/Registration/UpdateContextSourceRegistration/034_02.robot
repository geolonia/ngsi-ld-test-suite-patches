*** Settings ***
Documentation       Check that you cannot update a context source registration under some conditions

Resource            ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Setup Initial Entities
Test Template       Update Context Source


*** Variables ***
${registration_id_prefix}=              urn:ngsi-ld:Registration:
${filename}=                            context-source-registration-simple-sample.jsonld
${registration_payload_file_path}=      context-source-registration-invalid-sample.jsonld


*** Test Cases ***
034_02_01 Update a context source registration by id if the Id is not present
    Update Context Source
    ...    ${EMPTY}
    ...    fragments/context-source-registration-different-type-sample.jsonld
034_02_02 Update a context source registration by id if the Id is not a valid URI
    Update Context Source
    ...    invalidURI
    ...    fragments/context-source-registration-different-type-sample.jsonld
034_02_03 Update a context source registration if the request body is not of the same data type
    Update Context Source
    ...    ${valid_registration_id}
    ...    fragments/context-source-registration-different-type-sample.jsonld
034_02_04 Update a context source registration if you attempt to remove a mandatory property
    Update Context Source
    ...    ${valid_registration_id}
    ...    context-source-registration-invalid-structure-sample.jsonld


*** Keywords ***
Update Context Source
    [Documentation]    Check that you cannot update a context source registration under some conditions
    [Tags]    csr-update
    [Arguments]    ${registration_id}    ${fragment_filename}
    ${payload}=    Load JSON From File    ${EXECDIR}/data/csourceRegistrations/${filename}
    ${updated_payload}=    Update Value To JSON    ${payload}    $..id    ${valid_registration_id}
    ${response}=    Create Context Source Registration With Return    ${updated_payload}
    Check Response Status Code    201    ${response.status_code}
    ${fragment}=    Load JSON From File    ${EXECDIR}/data/csourceRegistrations/${fragment_filename}
    ${fragment_with_id}=    Update Value To JSON    ${fragment}    $..id    ${registration_id}
    ${response}=    Update Context Source Registration With Return
    ...    ${registration_id}
    ...    ${fragment_with_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    400    ${response.status_code}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}
    [Teardown]    Delete Context Source Registration    ${valid_registration_id}

Setup Initial Entities
    ${valid_registration_id}=    Generate Random Entity Id    ${registration_id_prefix}
    Set Suite Variable    ${valid_registration_id}
