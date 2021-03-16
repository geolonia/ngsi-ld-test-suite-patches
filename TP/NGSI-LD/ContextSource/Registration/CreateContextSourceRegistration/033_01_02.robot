*** Settings ***
Documentation   Check that you can create a context source registration that never expires
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource


*** Variable ***
${registration_id_prefix}=  urn:ngsi-ld:Registration:
${registration_payload_file_path}=   csourceRegistrations/context-source-registration-simple-sample.jsonld

*** Test Case ***
Create Context Source Registration That Never Expires
    [Documentation]  Check that you can create a context source registration that never expires
    [Tags]  /csourceRegistrations/    5_9_2
    ${registration_id}=     Generate Random Entity Id    ${registration_id_prefix}

    ${payload}=    Load Json From File    ${EXECDIR}/data/${registration_payload_file_path}
    ${updated_payload}=    Update Value To Json    ${payload}     $..id   ${registration_id}
    ${request}    ${response}=    Create Context Source Registration With Return  ${updated_payload}
    Check Response Status Code  201    ${response['status']}
    Check Response Headers Containing URI set to    ${request['path']}/    ${registration_id}  ${response}

    [Teardown]  Delete Context Source Registration    ${registration_id}
