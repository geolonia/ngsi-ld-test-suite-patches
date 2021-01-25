*** Settings ***
Documentation   Create a context source registration with invalid JSON file
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${registration_id_prefix}=  urn:ngsi-ld:Registration:
${registration_payload_file_path}=   registration-invalid-sample.jsonld

*** Test Cases ***              
Create a context source registration with invalid JSON file
    [Documentation]  Create a context source registration with invalid JSON file
    [Tags]  mandatory
    ${registration_id}=     Generate Random Entity Id    ${registration_id_prefix}

    ${response}=    Create Context Source Registration Using Session  ${registration_payload_file_path}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  <Response [400]>    ${response}
    Check Response Body Type When Using Session Request      ${response.json()}     ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Title When Using Session Request    ${response.json()}

    [Teardown]  Delete Entity by Id Returning Response   ${registration_id}