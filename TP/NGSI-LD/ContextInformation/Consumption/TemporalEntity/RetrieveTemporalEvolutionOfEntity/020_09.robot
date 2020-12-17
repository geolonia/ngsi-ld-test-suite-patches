*** Settings ***
Documentation   Check that you cannot retrieve the temporal evolution of an entity with an invalid request content
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Suite Setup      Setup Initial Entities
Suite Teardown      Delete Initial Entities
Test Template  Retrieve the temporal evolution of an entity with an invalid request content

*** Variable ***
${vehicule_id_prefix}=  urn:ngsi-ld:Vehicle:
${vehicle_payload_file}=  2020-08-vehicule-temporal-representation-sample.jsonld

*** Test Cases ***                        TIMEREL       TIMEAT                      ENDTIMEAT
After                                     after         ${EMPTY}                  ${EMPTY}
Before                                    before        ${EMPTY}                  ${EMPTY}
Between                                   between       2020-08-01T12:00:00Z      ${EMPTY}

*** Keywords ***
Retrieve the temporal evolution of an entity with an invalid request content
    [Arguments]  ${timerel}     ${timeAt}   ${endTimeAt}
    [Documentation]  Check that you cannot retrieve the temporal evolution of an entity with an invalid request content
    [Tags]  mandatory

    Retrieve Temporal Representation Of Entity   ${temporal_entity_representation_id}   timerel=${timerel}      timeAt=${timeAt}    endTimeAt=${endTimeAt}

    Check Response Status Code Set To  400
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}

Setup Initial Entities
    ${temporal_entity_representation_id}=     Generate Random Entity Id    ${vehicule_id_prefix}
    Create Temporal Representation Of Entity  ${vehicle_payload_file}     ${temporal_entity_representation_id}
    Set Suite Variable  ${temporal_entity_representation_id}

Delete Initial Entities
    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
