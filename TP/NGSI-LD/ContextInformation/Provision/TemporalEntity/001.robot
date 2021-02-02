*** Settings ***
Documentation   Check that you can create a temporal representation of an entity
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Create Temporal Entity

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:

*** Test Cases ***                                                                                             FILENAME                                                          CONTENT_TYPE
001_01_Create a temporal representation of an entity with simplified temporal representation of an Entity      vehicle-simplified-temporal-representation-sample.jsonld          application/json
001_02_Create a temporal representation of an entity with simple temporal properties                           vehicle-temporal-representation-sample.jsonld                     application/ld+json
001_03_Create an temporal entity with no context                                                               vehicle-temporal-representation-withou-context-sample.jsonld      application/ld+json

*** Keywords ***
Create Temporal Entity
    [Arguments]  ${filename}    ${content_type}
    [Documentation]  Check that you can create a temporal representation of an entity
    [Tags]  mandatory

    ${temporal_entity_representation_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${response}=  Create Temporal Representation Of Entity Selecting Content Type  ${temporal_entity_representation_id}    ${filename}     ${content_type}
    Check Response Status Code  201    ${response['status']}

    [Teardown]    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}