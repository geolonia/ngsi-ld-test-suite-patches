*** Settings ***
Documentation   Check that you cannot delete a context source registration under some conditions
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Delete Context Source

*** Variable ***
${registration_id_prefix}=  urn:ngsi-ld:Registration:
${filename}=  context-source-registration-simple-sample.jsonld

*** Test Case ***                                                                 INVALID_REGISTRATION_ID
035_02_01_Delete a Context Source Registration if the Id is not present              ${EMPTY}
035_02_02_Delete a Context Source Registration if the Id is not a valid URI          invalidURI

*** Keywords ***
Delete Context Source
    [Arguments]  ${invalid_registration_id}
    [Documentation]  Check that you cannot delete a context source registration under some conditions
    [Tags]  csr-delete

    ${registration_id}=     Generate Random Entity Id    ${registration_id_prefix}
    ${payload}=    Load Json From File    ${EXECDIR}/data/csourceRegistrations/${filename}
    ${updated_payload}=    Update Value To Json    ${payload}     $..id   ${registration_id}
    ${request}    ${response}=    Create Context Source Registration With Return  ${updated_payload}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Delete Context Source Registration With Return    ${invalid_registration_id}
    Check Response Status Code  400    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Title Element     ${response}

    [Teardown]  Delete Context Source Registration    ${registration_id}