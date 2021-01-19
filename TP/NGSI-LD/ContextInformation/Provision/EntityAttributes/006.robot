*** Settings ***
Documentation   Check that you cannot update entity attributes if the entity id or attributes are not known to the system
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${fragment_filename}=  vehicle-two-datasetid-attributes-sample-01.jsonld

*** Test Cases ***  
006_Update entity attributes when the entity id is not known to the system
    [Documentation]  Check that you cannot update entity attributes if the entity id or attributes are not known to the system
    [Tags]  mandatory

    ${entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${response}=    Update Entity Attributes    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  404    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_RESOURCE_NOT_FOUND}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}

*** Keywords ***
    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}