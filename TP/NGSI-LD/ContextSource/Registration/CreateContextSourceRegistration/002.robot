*** Settings ***
Documentation   Check that you cannot create a context source with invalid content
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Create Context Source With Invalid Content


*** Variable ***
${registration_id_prefix}=  urn:ngsi-ld:Registration:

*** Test Cases ***                                                                                                     FILENAME
002_02_Create a context source registration with a different data structure than CsourRegistration data type           csourceRegistrations/registration-invalid-structure-sample.jsonld
002_03_Create a context source registration with a date in the past                                                    csourceRegistrations/registration-past-expiration-sample.jsonld

*** Keywords ***
Create Context Source With Invalid Content
    [Arguments]  ${filename}
    [Documentation]  Check that you cannot create a context source with invalid content
    [Tags]  mandatory
    ${registration_id}=     Generate Random Entity Id    ${registration_id_prefix}

    ${payload}=    Load Json From File    ${EXECDIR}/data/${filename}
    ${updated_payload}=    Update Value To Json    ${payload}     $..id   ${registration_id}
    ${request}    ${response}=    Create Context Source Registration  ${updated_payload}
    Check Response Status Code  400    ${response['status']}
    Check Response Headers Containing URI set to    ${request['path']}/    ${registration_id}  ${response}

    [Teardown]  Delete Context Source Registration    ${registration_id}
