*** Settings ***
Documentation   Check that you cannot retrieve the temporal evolution of non-existing entity attributes
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Suite Setup      Setup Initial Entities
Suite Teardown      Delete Initial Entities

*** Variable ***
${vehicule_id_prefix}=  urn:ngsi-ld:Vehicle:
${vehicle_payload_file}=  2020-08-vehicule-temporal-representation-sample.jsonld

*** Test Case ***
Retrieve the temporal evolution of non-existing entity attributes
    [Documentation]  Check that you cannot retrieve the temporal evolution of non-existing entity attributes
    [Tags]  mandatory

    @{temporal_attributes_to_be_retrieved}=  Create List   unknownAttribute
    Retrieve Temporal Representation Of Entity   ${temporal_entity_representation_id}   attrs=${temporal_attributes_to_be_retrieved}    context=${ngsild_test_suite_context}

    Check Response Status Code Set To  404
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_RESOURCE_NOT_FOUND}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}

*** Keywords ***
Setup Initial Entities
    ${temporal_entity_representation_id}=     Generate Random Entity Id    ${vehicule_id_prefix}
    Create Temporal Representation Of Entity  ${vehicle_payload_file}     ${temporal_entity_representation_id}
    Set Suite Variable  ${temporal_entity_representation_id}

Delete Initial Entities
    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
