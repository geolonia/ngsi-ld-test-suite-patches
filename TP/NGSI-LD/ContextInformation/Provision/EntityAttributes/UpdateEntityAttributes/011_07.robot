*** Settings ***
Documentation       Check that one can delete an attribute using NGSI-LD Null in an Update Attributes operation

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Test Setup          Setup Initial Entity
Test Teardown       Delete Initial Entity
Test Template       Update Attributes


*** Variables ***
${vehicle_id_prefix}=       urn:ngsi-ld:Vehicle:
${filename}=                building-different-attributes-types.jsonld


*** Test Cases ***    STATUS_CODE    FRAGMENT_FILENAME    EXPECTATION_FILENAME
011_07_01 Delete a Property
    [Tags]    ea-update    5_6_2    6_6_3_2    since_v1.6.1
    204    ngsild-null/null-property.jsonld    ngsild-null/building-deleted-property.jsonld
011_07_02 Delete a Relationship
    [Tags]    ea-update    5_6_2    6_6_3_2    since_v1.6.1
    204    ngsild-null/null-relationship.jsonld    ngsild-null/building-deleted-relationship.jsonld
011_07_03 Delete a GeoProperty
    [Tags]    ea-update    5_6_2    6_6_3_2    since_v1.6.1
    204    ngsild-null/null-geoproperty.jsonld    ngsild-null/building-deleted-geoproperty.jsonld
011_07_04 Delete a LanguageProperty
    [Tags]    ea-update    5_6_2    6_6_3_2    4_5_18    since_v1.6.1
    204    ngsild-null/null-languageproperty.jsonld    ngsild-null/building-deleted-languageproperty.jsonld


*** Keywords ***
Update Attributes
    [Documentation]    Check that one can delete an attribute using NGSI-LD Null in an Update Attributes operation
    [Arguments]
    ...    ${status_code}
    ...    ${fragment_filename}
    ...    ${expectation_filename}
    ${response}=    Update Entity Attributes
    ...    ${entity_id}
    ...    ${fragment_filename}
    ...    ${CONTENT_TYPE_LD_JSON}

    Check Response Status Code    ${status_code}    ${response.status_code}
    ${response1}=    Retrieve Entity by Id
    ...    id=${entity_id}
    ...    context=${ngsild_test_suite_context}
    ...    accept=${CONTENT_TYPE_LD_JSON}
    Check Response Body Containing Entity element
    ...    expectation_filename=${expectation_filename}
    ...    entity_id=${entity_id}
    ...    response_body=${response1.json()}

Delete Initial Entity
    Delete Entity by Id    ${entity_id}

Setup Initial Entity
    ${entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    Set Test Variable    ${entity_id}
    ${response}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
