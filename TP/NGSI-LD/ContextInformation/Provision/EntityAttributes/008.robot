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

*** Test Cases ***                                                                  ENTITY_ID               ATTRIBUTE_ID          FRAGMENT_FILENAME
008_01_Make a partial attribute update if the Entity Id is not present              ${EMPTY}                speed                 vehicle-fragment-equal-datasetid-sample.jsonld
008_02_Make a partial attribute update if the Entity Id is not a valid URI          thisisaninvaliduri      speed                 vehicle-fragment-equal-datasetid-sample.jsonld
008_03_Make a partial attribute update if the Attribute Name is not present         ${valid_entity_id}      speed                 vehicle-fragment-attribute-name-missing-sample.jsonld
008_04_Make a partial attribute update if the Attribute Id is invalid               ${valid_entity_id}      invalid               vehicle-fragment-equal-datasetid-sample.jsonld
008_05_Make a partial attribute update if the Attribute type does not match         ${valid_entity_id}      speed                 vehicle-fragment-equal-datasetid-different-type-sample.jsonld
008_06_Make a partial attribute update if the entity fragment is empty              ${valid_entity_id}      speed                 vehicle-fragment-all-empty-sample.jsonld

*** Keywords ***
Update Attributes
    [Arguments]  ${entity_id}     ${attribute_id}     ${fragment_filename}
    [Documentation]  Check that you cannot perform a partial update on an entity attribute with invalid/missing ids
    [Tags]  mandatory  failing

    ${init_entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${init_entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Partial Update Entity Attributes    ${entity_id}    ${attribute_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  ${status_code}    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}

    [Teardown]  Delete Entity by Id Returning Response   ${init_entity_id}

Setup Initial Entities
    ${valid_entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    Set Suite Variable  ${valid_entity_id}