*** Settings ***
Documentation   Check that you can retrieve the temporal evolution of an entity matching the given NGSI-LD temporal query
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Suite Setup      Setup Initial Entities
Test Template  Retrieve the temporal evolution of an entity matching the given NGSI-LD temporal query

*** Variable ***
${vehicule_id_prefix}=  urn:ngsi-ld:Vehicle:
${vehicle_payload_file}=  vehicule-temporal-representation-sample.jsonld

*** Test Cases ***                        TIMEREL       TIME                      ENDTIME                   VEHICLE_EXPECTATION_FILE
After                                     after         2018-08-01T13:03:00Z        ${EMPTY}                vehicle-temporal-representation-020-04-01-expectation.jsonld
Before                                    before        2018-08-01T12:05:00Z        ${EMPTY}                vehicle-temporal-representation-020-04-02-expectation.jsonld
Between                                   between       2018-08-01T12:00:00Z        2018-08-01T13:00:00Z    vehicle-temporal-representation-020-04-03-expectation.jsonld

*** Keywords ***
Retrieve the temporal evolution of an entity matching the given NGSI-LD temporal query
    [Arguments]  ${timerel}     ${time}   ${endTime}    ${vehicle_expectation_file}
    [Documentation]  Check that you can retrieve the temporal evolution of an entity matching the given NGSI-LD temporal query
    [Tags]  mandatory

    Retrieve Temporal Representation Of Entity   ${temporal_entity_representation_id}   timerel=${timerel}      time=${time}    endTime=${endTime}  context=${ngsild_test_suite_context}
    
    Check Response Status Code Set To  200
    Check Response Body Containing EntityTemporal element       ${vehicle_expectation_file}    ${temporal_entity_representation_id}


Setup Initial Entities
    ${temporal_entity_representation_id}=     Generate Random Entity Id    ${vehicule_id_prefix}
    Create Temporal Representation Of Entity  ${vehicle_payload_file}     ${temporal_entity_representation_id}
    Set Suite Variable  ${temporal_entity_representation_id}

#TODO Call Suite Teardown