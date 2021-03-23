*** Settings ***
Documentation   Check that you cannot perform a partial update on an entity attribute with invalid/missing ids
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Suite Setup      Setup Initial Entities
Test Template  Update Attributes

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${filename}=  vehicle-two-datasetid-attributes-sample.jsonld
${status_code}=  400

*** Test Cases ***                                                                     ENTITY_ID               ATTRIBUTE_ID          FRAGMENT_FILENAME
012_02_01_Make a partial attribute update if the Entity Id is not present              ${EMPTY}                speed                 vehicle-speed-equal-datasetid-fragment.jsonld
012_02_02_Make a partial attribute update if the Entity Id is not a valid URI          thisisaninvaliduri      speed                 vehicle-speed-equal-datasetid-fragment.jsonld
012_02_03_Make a partial attribute update if the Attribute Name is not present         ${valid_entity_id}      speed                 vehicle-speed-wrong-name-fragment.jsonld
012_02_04_Make a partial attribute update if the Attribute Id is invalid               ${valid_entity_id}      invalid               vehicle-speed-equal-datasetid-fragment.jsonld
012_02_05_Make a partial attribute update if the Attribute type does not match         ${valid_entity_id}      speed                 vehicle-speed-equal-datasetid-different-type-fragment.jsonld
012_02_06_Make a partial attribute update if the entity fragment is empty              ${valid_entity_id}      speed                 empty-fragment.json

*** Keywords ***
Update Attributes
    [Arguments]  ${entity_id}     ${attribute_id}     ${fragment_filename}
    [Documentation]  Check that you cannot perform a partial update on an entity attribute with invalid/missing ids
    [Tags]  /entities/{entityId}/attrs/{attrId}      5_6_4

    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${valid_entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Partial Update Entity Attributes    ${entity_id}    ${attribute_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  ${status_code}    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}

    [Teardown]  Delete Entity by Id Returning Response   ${valid_entity_id}

Setup Initial Entities
    ${valid_entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    Set Suite Variable  ${valid_entity_id}