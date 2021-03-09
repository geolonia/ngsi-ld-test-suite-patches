*** Settings ***
Documentation   Check that you cannot append entity attributes if the entity id or attributes are not known to the system
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${fragment_filename}=  vehicle-attribute-to-add-fragment.jsonld

*** Test Cases ***  
Append entity attributes when the entity id is not known to the system
    [Documentation]  Check that you cannot append entity attributes if the entity id or attributes are not known to the system
    [Tags]  mandatory

    ${entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${response}=    Append Entity Attributes    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}    ${EMPTY}
    Check Response Status Code  404    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_RESOURCE_NOT_FOUND}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}

*** Keywords ***
    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}