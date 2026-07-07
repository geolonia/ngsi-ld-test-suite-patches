*** Settings ***
Documentation       Check that sub-attributes set to NGSI-LD Null in a Merge Entity operation are removed

Resource            ${EXECDIR}/resources/ApiUtils/Common.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Setup Initial Entity
Test Teardown       Delete Initial Entity
Test Template       Merge Entity Scenarios


*** Variables ***
${entity_payload_filename}=     building-relationship-of-property.jsonld


*** Test Cases ***    FILENAME    EXPECTATION_FILENAME
056_07_01 RemoveUnitCodeFromProperty
    [Tags]    e-merge    5_6_17    6_5_3_4    since_v1.6.1
    fragmentEntities/ngsild-null/building-null-sub-property-unitcode.jsonld    ngsild-null/building-deleted-unitcode.jsonld
056_07_02 RemoveSubAttributeFromProperty
    [Tags]    e-merge    5_6_17    6_5_3_4    since_v1.6.1
    fragmentEntities/ngsild-null/building-null-sub-property-sub-attribute.jsonld    ngsild-null/building-deleted-sub-attribute.jsonld


*** Keywords ***
Merge Entity Scenarios
    [Documentation]    Check that sub-attributes set to NGSI-LD Null in a Merge Entity operation are removed
    [Arguments]    ${filename}    ${expectation_filename}
    ${response}=    Merge Entity
    ...    entity_id=${entity_id}
    ...    entity_filename=${filename}
    ...    content_type=${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    204    ${response.status_code}
    Check Response Body Is Empty    ${response}

    ${response1}=    Retrieve Entity
    ...    id=${entity_id}
    ...    context=${ngsild_test_suite_context}
    ...    accept=${CONTENT_TYPE_LD_JSON}
    Check Response Body Containing Entity element
    ...    expectation_filename=${expectation_filename}
    ...    entity_id=${entity_id}
    ...    response_body=${response1.json()}

Setup Initial Entity
    ${entity_id}=    Generate Random Building Entity Id
    ${response}=    Create Entity    ${entity_payload_filename}    ${entity_id}
    Set Test Variable    ${entity_id}
    Check Response Status Code    201    ${response.status_code}

Delete Initial Entity
    Delete Entity    ${entity_id}
