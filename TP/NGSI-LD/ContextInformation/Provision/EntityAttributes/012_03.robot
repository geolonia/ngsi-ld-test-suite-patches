*** Settings ***
Documentation   Check that you cannot perform a partial update on an entity attribute if the entity id or attribute is not known to the system
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Suite Setup      Setup Initial Entities
Test Template  Partial Update Attributes

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${filename}=  vehicle-datasetid-attributes-sample.jsonld
${status_code}=  404
${attribute_id}=  speed

*** Test Cases ***                                                                   ENTITY_ID                      FRAGMENT_FILENAME      
012_03_01_Partial update when the Entity Id is not known to the system               ${not_found_entity_id}         vehicle-fragment-same-datasetid-sample.jsonld
012_03_02_Partial update when no default instance and no datasetId specified         ${valid_entity_id}             vehicle-fragment-invalid-datasetid-sample.jsonld
012_03_03_Partial update when no instance with the datasetId specified               ${valid_entity_id}             vehicle-fragment-empty-datasetid-sample.jsonld
012_03_04_Partial update when no instance with the attrId specified                  ${valid_entity_id}             vehicle-fragment-attribute-name-missing-sample.jsonld

*** Keywords ***
Partial Update Attributes
    [Arguments]  ${entity_id}     ${fragment_filename}
    [Documentation]  Check that you cannot perform a partial update on an entity attribute if the entity id or attribute is not known to the system
    [Tags]  mandatory

    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${valid_entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Partial Update Entity Attributes    ${entity_id}    ${attribute_id}    ${fragment_filename}    ${CONTENT_TYPE_JSON}
    Check Response Status Code  ${status_code}    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_RESOURCE_NOT_FOUND}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}

    [Teardown]  Delete Entity by Id Returning Response   ${valid_entity_id}

Setup Initial Entities
    ${valid_entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    Set Suite Variable  ${valid_entity_id}
    ${not_found_entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    Set Suite Variable  ${not_found_entity_id}