*** Settings ***
Documentation       Check that one can filter attribute instances based on datasetId.

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Setup Initial Entity
Suite Teardown      Delete Entity
Test Template       Filter attribute instances based on datasetId


*** Variables ***
${filename}     building-multi-instances-attributes.jsonld


*** Test Cases ***    ATTRS    DATASET_ID    EXPECTATION_FILENAME
019_12_01 filter based on attrs only
    [Tags]    e-query    4_5_5    5_7_2    since_v1.8.1
    name    ${EMPTY}    building-name-attribute.jsonld
019_12_02 filter based on datasetId only
    [Tags]    e-query    4_5_5    5_7_2    since_v1.8.1
    ${EMPTY}    urn:ngsi-ld:Dataset:french-name    building-french-datasetid-only.jsonld
019_12_03 filter based on two datasetIds
    [Tags]    e-query    4_5_5    5_7_2    since_v1.8.1
    ${EMPTY}    urn:ngsi-ld:Dataset:french-name,urn:ngsi-ld:Dataset:spanish-name    building-two-datasetids.jsonld
019_12_04 filter based on default instance
    [Tags]    e-query    4_5_5    5_7_2    since_v1.8.1
    ${EMPTY}    @none    building-default-instances.jsonld
019_12_05 filter based on attrs and default instance
    [Tags]    e-query    4_5_5    5_7_2    since_v1.8.1
    name    @none    building-name-attribute-default-instance.jsonld
019_12_06 filter based on attrs and datasetId
    [Tags]    e-query    4_5_5    5_7_2    since_v1.8.1
    name    urn:ngsi-ld:Dataset:german-name    building-name-attribute-german-instance.jsonld
019_12_07 filter based on attrs and datasetId with no match
    [Tags]    e-query    4_5_5    5_7_2    since_v1.8.1
    name    urn:ngsi-ld:Dataset:spanish-name    building-no-attributes.jsonld


*** Keywords ***
Filter attribute instances based on datasetId
    [Documentation]    Check that one can filter attribute instances based on datasetId.
    [Arguments]    ${attrs}    ${datasetId}    ${expectation_filename}

    ${attrsToMatch}=    Catenate
    ...    SEPARATOR=,
    ...    ${attrs}

    ${response}=    Query Entities
    ...    attrs=${attrsToMatch}
    ...    datasetId=${datasetId}
    ...    entity_types=Building
    ...    context=${ngsild_test_suite_context}
    ...    accept=${CONTENT_TYPE_LD_JSON}

    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing Entity element
    ...    expectation_filename=${expectation_filename}
    ...    entity_id=${entity_id}
    ...    response_body=${response.json()[0]}

Setup Initial Entity
    ${entity_id}=    Generate Random Building Entity Id
    Set Suite Variable    ${entity_id}
    ${create_response}=    Create Entity Selecting Content Type
    ...    ${filename}
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${create_response.status_code}

Delete Entity
    Delete Entity by Id    ${entity_id}
