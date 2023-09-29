*** Settings ***
Documentation       Check that you cannot retrieve the temporal evolution of non-existing entity attributes

Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource

Suite Setup         Setup Initial Entities
Suite Teardown      Delete Initial Entities


*** Variables ***
${vehicule_id_prefix}=      urn:ngsi-ld:Vehicle:
${vehicle_payload_file}=    2020-08-vehicule-temporal-representation-sample.jsonld


*** Test Cases ***
020_08_01 Retrieve the temporal evolution of non-existing entity attributes
    [Documentation]    Check that you cannot retrieve the temporal evolution of non-existing entity attributes
    [Tags]    te-retrieve    5_7_3
    @{temporal_attributes_to_be_retrieved}=    Create List    unknownAttribute
    ${response}=    Retrieve Temporal Representation Of Entity
    ...    ${temporal_entity_representation_id}
    ...    attrs=${temporal_attributes_to_be_retrieved}
    ...    context=${ngsild_test_suite_context}
    Check Response Status Code    404    ${response.status_code}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    ...    ${response.json()}
    ...    ${ERROR_TYPE_RESOURCE_NOT_FOUND}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response.json()}


*** Keywords ***
Setup Initial Entities
    ${temporal_entity_representation_id}=    Generate Random Entity Id    ${vehicule_id_prefix}
    Create Temporal Representation Of Entity    ${vehicle_payload_file}    ${temporal_entity_representation_id}
    Set Suite Variable    ${temporal_entity_representation_id}

Delete Initial Entities
    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
