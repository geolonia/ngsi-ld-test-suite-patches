*** Settings ***
Documentation   Check that you can update a context source registration by id
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Update Context Source

*** Variable ***
${registration_id_prefix}=  urn:ngsi-ld:Registration:

*** Test Case ***                                                     FILENAME                                                          UPDATE_FILENAME
034_01_01_Update a context source registration by id                  context-source-registration-sample.jsonld                         context-source-registration-with-expiration-sample.jsonld
034_01_02_Update a context source registration to never expire        context-source-registration-with-expiration-sample.jsonld         context-source-registration-simple-sample.jsonld

*** Keywords ***
Update Context Source
    [Arguments]  ${filename}    ${update_filename}  
    [Documentation]  Check that you can update a context source registration by id
    [Tags]  /csourceRegistrations/{registrationId}    5_9_3
    
    ${registration_id}=     Generate Random Entity Id    ${registration_id_prefix}
    ${payload}=    Load Json From File    ${EXECDIR}/data/csourceRegistrations/${filename}
    ${registration_payload}=    Update Value To Json    ${payload}     $..id   ${registration_id}
    ${request}    ${response}=    Create Context Source Registration With Return  ${registration_payload}
    Check Response Status Code  201    ${response['status']}

    ${fragment}=    Load Json From File    ${EXECDIR}/data/csourceRegistrations/${update_filename}
    ${registration_update_fragment}=    Update Value To Json    ${fragment}     $..id   ${registration_id}
    ${response}=    Update Context Source Registration With Return  ${registration_id}    ${registration_update_fragment}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  204    ${response['status']}

    Retrieve Context Source Registration   ${registration_id}   context=${ngsild_test_suite_context}   accept=${CONTENT_TYPE_LD_JSON}
    ${ignored_attributes}=  Create List    ${status_regex_expr}    @context
    Check Updated Resource Set To     ${registration_payload}


    [Teardown]  Delete Context Source Registration    ${registration_id}
