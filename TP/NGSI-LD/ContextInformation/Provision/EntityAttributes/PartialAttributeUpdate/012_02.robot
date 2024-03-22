*** Settings ***
Documentation       Check that you cannot perform a partial update on an entity attribute with invalid/missing ids

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Setup Initial Entity
Test Teardown       Delete Initial Entity
Test Template       Update Attributes


*** Variables ***
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:
${filename}=                vehicle-two-datasetid-attributes-sample.jsonld
${status_code}=             400


*** Test Cases ***    ENTITY_ID    ATTRIBUTE_ID    FRAGMENT_FILENAME
012_02_01 Make a partial attribute update if the Entity Id is not present
    ${EMPTY}    speed    vehicle-speed-equal-datasetid-fragment.jsonld
012_02_02 Make a partial attribute update if the Entity Id is not a valid URI
    thisisaninvaliduri    speed    vehicle-speed-equal-datasetid-fragment.jsonld
012_02_03 Make a partial attribute update if the Attribute type does not match
    ${valid_entity_id}    speed    vehicle-speed-equal-datasetid-different-type-fragment.jsonld
012_02_04 Make a partial attribute update if the entity fragment is empty
    ${valid_entity_id}    speed    empty-fragment.json


*** Keywords ***
Update Attributes
    [Documentation]    Check that you cannot perform a partial update on an entity attribute with invalid/missing ids
    [Tags]    ea-partial-update    5_6_4
    [Arguments]    ${entity_id}    ${attribute_id}    ${fragment_filename}
    ${response}=    Partial Update Entity Attributes
    ...    entityId=${entity_id}
    ...    attributeId=${attribute_id}
    ...    fragment_filename=${fragment_filename}
    ...    content_type=${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    ${status_code}    ${response.status_code}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()}
    ...    ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}

Setup Initial Entity
    ${valid_entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    Set Test Variable    ${valid_entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${valid_entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}

Delete Initial Entity
    Delete Entity by Id    ${valid_entity_id}
