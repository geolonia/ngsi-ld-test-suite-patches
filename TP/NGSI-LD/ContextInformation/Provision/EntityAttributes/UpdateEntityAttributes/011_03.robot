*** Settings ***
Documentation     Check that you cannot update entity attributes if the entity id or attributes are not known to the system
Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${vehicle_id_prefix}=    urn:ngsi-ld:Vehicle:
${fragment_filename}=    vehicle-speed-two-datasetid-01-fragment.jsonld

*** Test Cases ***
Update entity attributes when the entity id is not known to the system
    [Documentation]    Check that you cannot update entity attributes if the entity id or attributes are not known to the system
    [Tags]    ea-update    5_6_2
    ${entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    ${response}=    Update Entity Attributes    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    404    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to    ${response}    ${ERROR_TYPE_RESOURCE_NOT_FOUND}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}

*** Keywords ***

    [Teardown]    Delete Entity by Id Returning Response    ${entity_id}
