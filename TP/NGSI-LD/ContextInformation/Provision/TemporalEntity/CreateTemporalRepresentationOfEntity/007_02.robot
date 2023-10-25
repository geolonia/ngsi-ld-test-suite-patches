*** Settings ***
Documentation       Check that you cannot create a temporal entity with an empty/invalid json/id

Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationProvision/ApiUtils.resource
# Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Template       Create Temporal Entity From File


*** Variables ***
${status_code}=     400


*** Test Cases ***    FILENAME
007_02_01 Create a temporal entity with an invalid json
    vehicle-temporal-representation-invalid-json-sample.jsonld
007_02_02 Create a temporal entity with an empty json
    vehicle-temporal-representation-empty-json-sample.jsonld


*** Keywords ***
Create Temporal Entity From File
    [Documentation]    Check that you cannot create a temporal entity with an empty/invalid json/id
    [Tags]    te-create    5_6_11
    [Arguments]    ${filename}
    ${response}=    Create Temporal Representation Of Entity Selecting Content Type
    ...    ${filename}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    400    ${response.status_code}
    Check Response Body Type When Using Session Request    ${response.json()}    ${ERROR_TYPE_INVALID_REQUEST}
    Check Response Body Title When Using Session Request    ${response.json()}
