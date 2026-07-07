*** Settings ***
Documentation       Check that sub-attributes set to NGSI-LD Null in a Partial Attribute Update are removed

Resource            ${EXECDIR}/resources/ApiUtils/Common.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Initiate Test Case
Test Teardown       Delete Initial Entities
Test Template       Update Attributes


*** Variables ***
${filename}=    building-relationship-of-property.jsonld


*** Test Cases ***    FRAGMENT_FILENAME    ATTRIBUTE_ID    EXPECTATION_FILENAME
012_10_01 RemoveObservedAtFromAirQualityLevel
    [Tags]    ea-partial-update    5_6_4    6_7_3_1    since_v1.6.1
    ngsild-null/null-sub-property-observedat-fragment.jsonld    airQualityLevel    ngsild-null/building-deleted-observedat.jsonld
012_10_02 RemoveUnitCodeFromAirQualityLevel
    [Tags]    ea-partial-update    5_6_4    6_7_3_1    since_v1.6.1
    ngsild-null/null-sub-property-unitcode-fragment.jsonld    airQualityLevel    ngsild-null/building-deleted-unitcode.jsonld
012_10_03 RemoveSubAttributeFromAirQualityLevel
    [Tags]    ea-partial-update    5_6_4    6_7_3_1    since_v1.6.1
    ngsild-null/null-sub-property-sub-attribute-fragment.jsonld    airQualityLevel    ngsild-null/building-deleted-sub-attribute.jsonld


*** Keywords ***
Update Attributes
    [Documentation]    Check that sub-attributes set to NGSI-LD Null in a Partial Attribute Update are removed
    [Arguments]    ${fragment_filename}    ${attribute_id}    ${expectation_filename}
    ${response}=    Partial Update Entity Attributes
    ...    entityId=${entity_id}
    ...    attributeId=${attribute_id}
    ...    fragment_filename=${fragment_filename}
    ...    content_type=${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    204    ${response.status_code}
    Check Response Body Is Empty    ${response}
    ${entity_expectation_payload}=    Load Test Sample    entities/expectations/${expectation_filename}    ${entity_id}
    ${response1}=    Retrieve Entity
    ...    id=${entity_id}
    ...    context=${ngsild_test_suite_context}
    ...    accept=${CONTENT_TYPE_LD_JSON}
    ${ignored_attributes}=    Create List    @context
    Check Updated Resource Set To
    ...    updated_resource=${entity_expectation_payload}
    ...    response_body=${response1.json()}
    ...    ignored_keys=${ignored_attributes}

Initiate Test Case
    ${entity_id}=    Generate Random Building Entity Id
    Set Test Variable    ${entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}

Delete Initial Entities
    Delete Entity    ${entity_id}
