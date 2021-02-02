*** Settings ***
Documentation   Check that you cannot update a context source registration if the request body is invalid
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${registration_id_prefix}=  urn:ngsi-ld:Registration:
${filename}=  registration-sample.jsonld
${registration_payload_file_path}=  registration-invalid-sample.jsonld

*** Test Case ***
Update a context source registration if the request body is invalid 
    [Documentation]  Check that you cannot update a context source registration if the request body is invalid
    [Tags]  mandatory
    ${registration_id}=     Generate Random Entity Id    ${registration_id_prefix}
    ${payload}=    Load Json From File    ${EXECDIR}/data/csourceRegistrations/${filename}
    ${updated_payload}=    Update Value To Json    ${payload}     $..id   ${registration_id}
    ${request}    ${response}=    Create Context Source Registration With Return  ${updated_payload}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Update Context Source Registration Using Session  ${registration_id}    ${registration_payload_file_path}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  <Response [400]>    ${response}
    Check Response Body Type When Using Session Request      ${response.json()}     ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Title When Using Session Request    ${response.json()}

    [Teardown]  Delete Context Source Registration    ${registration_id}
