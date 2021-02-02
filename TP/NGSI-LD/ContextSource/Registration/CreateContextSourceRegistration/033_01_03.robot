*** Settings ***
Documentation   Check that when creating a context source registration without specifying an ID
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource


*** Variable ***
${registration_id_prefix}=  urn:ngsi-ld:Registration:
${registration_payload_file_path}=   csourceRegistrations/registration-no-id-sample.jsonld

*** Test Case ***
Create Context Source Registration Without A Sprecified ID
    [Documentation]  Check that when creating a context source registration without specifying an ID
    [Tags]  mandatory

    ${payload}=    Load Json From File    ${EXECDIR}/data/${registration_payload_file_path}
    ${request}    ${response}=    Create Context Source Registration With Return  ${payload}
    Check Response Status Code  201    ${response['status']}
    ${registration_id}=    Check Response Headers ID Not Empty    ${response}

    [Teardown]  Delete Context Source Registration    ${registration_id}