*** Settings ***
Documentation   Check that you cannot create a context source registration that already exists
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource


*** Variable ***
${registration_id_prefix}=  urn:ngsi-ld:Registration:
${filename}=  csourceRegistrations/context-source-registration-simple-sample.jsonld

*** Test Cases ***
Create a context source registration that already exists
    [Documentation]  Check that you cannot create a context source registration that already exists
    [Tags]  csr-create
    ${registration_id}=    Generate Random Entity Id    ${registration_id_prefix}
    ${payload}=    Load Json From File    ${EXECDIR}/data/${filename}
    ${updated_payload}=    Update Value To Json    ${payload}     $..id   ${registration_id}
    ${request}    ${response}=    Create Context Source Registration With Return  ${updated_payload}
    Check Response Status Code  201    ${response['status']}

    ${request}    ${response}=    Create Context Source Registration With Return  ${updated_payload}
    Check Response Status Code  409    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Title Element     ${response}

    [Teardown]  Delete Context Source Registration    ${registration_id}
