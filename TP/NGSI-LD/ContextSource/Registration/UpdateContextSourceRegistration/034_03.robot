*** Settings ***
Documentation   Check that you cannot update a context source registration by id if the id is not known to the system
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${registration_id_prefix}=  urn:ngsi-ld:Registration:
${filename}=  context-source-registration-simple-sample.jsonld

*** Test Case ***
Update a context source registration by id if the id is not known to the system
    [Documentation]  Check that you cannot update a context source registration by id if the id is not known to the system
    [Tags]  mandatory
    ${registration_id}=     Generate Random Entity Id    ${registration_id_prefix}
    ${fragment}=    Load Json From File    ${EXECDIR}/data/csourceRegistrations/${filename}
    ${fragment_with_id}=    Update Value To Json    ${fragment}     $..id   ${registration_id}
    ${response}=    Update Context Source Registration With Return  ${registration_id}    ${fragment_with_id}
    Check Response Status Code  404    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Title Element     ${response}

    [Teardown]  Delete Context Source Registration    ${registration_id}
