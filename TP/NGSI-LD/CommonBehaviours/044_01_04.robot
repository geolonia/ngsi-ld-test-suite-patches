*** Settings ***
Documentation   Verify that PATCH HTTP requests can be done with "application/merge-patch+json" as Content-Type 
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${registration_id_prefix}=  urn:ngsi-ld:Registration:
${registration_payload_file_path}=   registration-sample.jsonld 
${fragment_filename_path}=  context-source-registration-update-sample.jsonld

*** Test Cases ***                               
044_01_04_endpoint /csourceRegistrations/{registrationId}  
    [Documentation]  Verify that PATCH HTTP requests can be done with "application/merge-patch+json" as Content-Type 
    [Tags]  mandatory
    ${registration_id}=     Generate Random Entity Id    ${registration_id_prefix}

    ${payload}=    Load Json From File    ${EXECDIR}/data/csourceRegistrations/${registration_payload_file_path}
    ${updated_payload}=    Update Value To Json    ${payload}     $..id   ${registration_id}
    ${request}    ${response}=    Create Context Source Registration With Return  ${updated_payload}
    Check Response Status Code  201    ${response['status']}

    ${fragment}=    Load Json From File    ${EXECDIR}/data/csourceRegistrations/fragments/${fragment_filename_path}
    ${response}=    Update Context Source Registration With Return  ${registration_id}    ${fragment}    ${CONTENT_TYPE_MERGE_PATCH_JSON}
    Check Response Status Code  204    ${response['status']}

    [Teardown]  Delete Context Source Registration    ${registration_id}