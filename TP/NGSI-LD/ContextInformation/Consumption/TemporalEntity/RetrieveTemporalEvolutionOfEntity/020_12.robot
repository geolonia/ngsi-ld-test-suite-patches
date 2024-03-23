*** Settings ***
Documentation       Check that you can retrieve the temporal evolution of an entity with a LanguageProperty property

Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Create Temporal Entity
Suite Teardown      Delete Initial Temporal Entity
Test Template       Retrieve Temporal Entity


*** Variables ***
${vehicule_id_prefix}=      urn:ngsi-ld:Vehicle:
${vehicle_payload_file}=    vehicle-language-property-temporal-representation-sample.jsonld


*** Test Cases ***    REPRESENTATION    EXPECTATION_FILENAME
020_12_01 Retrieve the normalized temporal representation of an entity with a LanguageProperty property
    [Tags]    te-retrieve    5_7_3    4_5_7    4_5_18    since_v1.4.1
    ${EMPTY}    vehicle-language-property-normalized-temporal-representation-expectation.jsonld
020_12_02 Retrieve the simplified temporal representation of an entity with a LanguageProperty property
    [Tags]    te-retrieve    5_7_3    4_5_9    4_5_18    since_v1.4.1
    temporalValues    vehicle-language-property-simplified-temporal-representation-expectation.jsonld


*** Keywords ***
Retrieve Temporal Entity
    [Documentation]    Check that you can retrieve the temporal evolution of an entity with a LanguageProperty property
    [Arguments]    ${representation}    ${expectation_filename}
    ${response}=    Retrieve Temporal Representation Of Entity
    ...    temporal_entity_representation_id=${temporal_entity_representation_id}
    ...    options=${representation}
    ...    context=${ngsild_test_suite_context}
    Check Response Status Code    200    ${response.status_code}
    Check Response Body Containing EntityTemporal element
    ...    ${expectation_filename}
    ...    ${temporal_entity_representation_id}
    ...    ${response.json()}

Create Temporal Entity
    ${temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicule_id_prefix}
    Create Temporal Representation Of Entity    ${vehicle_payload_file}    ${temporal_entity_representation_id}
    Set Suite Variable    ${temporal_entity_representation_id}

Delete Initial Temporal Entity
    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
