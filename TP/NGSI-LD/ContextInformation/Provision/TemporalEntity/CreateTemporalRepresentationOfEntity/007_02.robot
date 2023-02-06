*** Settings ***
Documentation     Check that you cannot create a temporal entity with an empty/invalid json/id
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${status_code}=    400

*** Test Cases ***
007_02_01_Create a temporal entity with an invalid json
    Create Temporal Entity From File    vehicle-temporal-representation-invalid-json-sample.jsonld

007_02_02_Create a temporal entity with an empty json
    Create Temporal Entity From File    vehicle-temporal-representation-empty-json-sample.jsonld

007_02_03_Create a temporal entity with missing id
    Create Temporal Entity    ${EMPTY}    vehicle-temporal-representation-without-id-sample.jsonld

007_02_04_Create a temporal invalid URI
    Create Temporal Entity    invalidId    vehicle-temporal-representation-sample.jsonld

*** Keywords ***
Create Temporal Entity From File
    [Arguments]    ${filename}
    [Documentation]    Check that you cannot create a temporal entity with an empty/invalid json/id
    [Tags]    te-create    5_6_11
    Create Temporal Representation Of Entity Selecting Content Type Using Session    ${filename}    ${CONTENT_TYPE_LD_JSON}
    Check RL Response Status Code Set To    400
    Check Response Body Type When Using Session Request    ${response.json()}    ${ERROR_TYPE_INVALID_REQUEST}
    Check Response Body Title When Using Session Request    ${response.json()}

Create Temporal Entity
    [Arguments]    ${entity_id}    ${filename}
    [Documentation]    Check that you cannot create a temporal entity with an invalid @context
    [Tags]    te-create    5_6_11
    ${response}=    Create Or Update Temporal Representation Of Entity Selecting Content Type    ${entity_id}    ${filename}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    ${status_code}    ${response['status']}
    [Teardown]    Delete Temporal Representation Of Entity    ${entity_id}
