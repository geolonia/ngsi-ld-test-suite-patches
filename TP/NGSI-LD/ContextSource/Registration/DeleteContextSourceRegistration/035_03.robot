*** Settings ***
Documentation   Check that you cannot delete a context source registration by id if the id is not known to the system
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource


*** Variable ***
${registration_id_prefix}=  urn:ngsi-ld:Registration:
${registration_payload_file_path}=   context-source-registration-simple-sample.jsonld

*** Test Case ***
Delete a context source registration by id
    [Documentation]  Check that you cannot delete a context source registration by id if the id is not known to the system
    [Tags]  mandatory
    ${registration_id}=     Generate Random Entity Id    ${registration_id_prefix}

    ${response}=    Delete Context Source Registration With Return    ${registration_id}
    Check Response Status Code  404    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Title Element     ${response}