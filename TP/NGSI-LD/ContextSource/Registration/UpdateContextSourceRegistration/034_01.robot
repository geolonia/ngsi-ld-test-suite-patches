*** Settings ***
Documentation   Check that you can update a context source registration by id
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Update Context Source

*** Variable ***
${registration_id_prefix}=  urn:ngsi-ld:Registration:

*** Test Case ***                                                     FILENAME                                           UPDATE_FILENAME
034_01_01_Update a context source registration by id                     context-source-registration-simple-sample.jsonld                         context-source-registration-with-expiration-sample.jsonld  
034_01_02_Update a context source registration to never expire           context-source-registration-with-expiration-sample.jsonld         context-source-registration-simple-sample.jsonld

*** Keywords ***
Update Context Source
    [Arguments]  ${filename}    ${update_filename}  
    [Documentation]  Check that you can update a context source registration by id
    [Tags]  mandatory
    ${registration_id}=     Generate Random Entity Id    ${registration_id_prefix}
    ${payload}=    Load Json From File    ${EXECDIR}/data/csourceRegistrations/${filename}
    ${updated_payload}=    Update Value To Json    ${payload}     $..id   ${registration_id}
    ${request}    ${response}=    Create Context Source Registration With Return  ${updated_payload}
    Check Response Status Code  201    ${response['status']}

    ${fragment}=    Load Json From File    ${EXECDIR}/data/csourceRegistrations/${update_filename}
    ${fragment_with_id}=    Update Value To Json    ${fragment}     $..id   ${registration_id}
    ${response}=    Update Context Source Registration With Return  ${registration_id}    ${fragment_with_id}
    Check Response Status Code  204    ${response['status']}

    [Teardown]  Delete Context Source Registration    ${registration_id}
