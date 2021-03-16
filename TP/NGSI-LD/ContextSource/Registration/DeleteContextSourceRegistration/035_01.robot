*** Settings ***
Documentation   Check that you can delete a context source registration by id
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource


*** Variable ***
${registration_id_prefix}=  urn:ngsi-ld:Registration:
${registration_payload_file_path}=   context-source-registration-simple-sample.jsonld

*** Test Case ***
Delete a context source registration by id
    [Documentation]  Check that you can delete a context source registration by id
    [Tags]  /csourceRegistrations/{registrationId}    5_9_4
    ${registration_id}=     Generate Random Entity Id    ${registration_id_prefix}
    ${payload}=    Load Json From File    ${EXECDIR}/data/csourceRegistrations/${registration_payload_file_path}
    ${updated_payload}=    Update Value To Json    ${payload}     $..id   ${registration_id}
    ${request}    ${response}=    Create Context Source Registration With Return  ${updated_payload}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Delete Context Source Registration With Return    ${registration_id}
    Check Response Status Code  204    ${response['status']}
