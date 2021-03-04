*** Settings ***
Documentation   Verify that on a GET HTTP request if nothing is specified on the Accept header, "application/json" is assumed
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${building_filename}=  building-simple-attributes-sample.jsonld
${vehicle_filename}=  vehicle-simple-attributes-sample.json
${building_expectation}=  building-simple-attributes-sample-expectation.json
${entity_type}=  https://ngsi-ld-test-suite/context#Building

${subscription_id_prefix}=  urn:ngsi-ld:Subscription:
${subscription_filename}=  csourceSubscriptions/subscription-sample.jsonld
${subscription_expectation}=  subscription-sample-expectation.json

${types_expectation}=  types/expectations/entity-type-list-022-01-01-expectation.json
${type_expectation}=  types/expectations/entity-type-info-024-01-expectation.json

${attributes_expectation}=  types/expectations/attribute-list-025-01-01-expectation.json
${attribute_expectation}=  types/expectations/attribute-027-01-expectation.json

${registration_id_prefix}=  urn:ngsi-ld:Registration:
${registration_filename}=   csourceRegistrations/registration-with-expiration-sample.jsonld
${registration_expectation}=  registration-with-expiration-expectation-sample.json
${registration_type}=  Vehicle

${tea_id_prefix}=  urn:ngsi-ld:Vehicle:
${tea_filename}=  vehicle-temporal-representation-sample.jsonld
${tea_expectation}=  vehicle-temporal-representation-expectation.json
${teatype}=  Vehicle


*** Test Cases ***
044_02_01_endpoint /entities/
    [Documentation]  Verify that on a GET HTTP request if nothing is specified on the Accept header, "application/json" is assumed (/entities/)
    ${id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${building_filename}     ${id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    @{entities_ids_to_be_compared}=  Create List   ${id}
    ${entities_ids_to_be_retrieved}=  Set Variable   ${id}

    @{entity_types_to_be_retrieved}=  Create List   ${entity_type}
    ${response}=    Query Entities    entity_ids=${entities_ids_to_be_retrieved}    entity_types=${entity_types_to_be_retrieved}
    Check Response Status Code  200    ${response['status']}
    Check Response Body Containing List Containing Entity elements    ${building_expectation}    ${entities_ids_to_be_compared}    ${response['body']}

    [Teardown]  Delete Entity by Id Returning Response   ${id}

044_02_02_endpoint /entities/{entityId}
    [Documentation]  Verify that on a GET HTTP request if nothing is specified on the Accept header, "application/json" is assumed (/entities/{entityId})
    ${id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${building_filename}     ${id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Query Entity    ${id}
    Check Response Status Code  200    ${response['status']}
    Check Response Body Containing Entity element    ${building_expectation}    ${id}    ${response['body']}

    [Teardown]  Delete Entity by Id Returning Response   ${id}

044_02_03_endpoint /subscriptions/
    [Documentation]  Verify that on a GET HTTP request if nothing is specified on the Accept header, "application/json" is assumed (/subscriptions/)

    ${id}=  Generate Random Entity Id    ${subscription_id_prefix}    
    ${response}=    Create Subscription    ${id}    ${subscription_filename}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=  Query Subscriptions
    Check Response Status Code  200    ${response['status']}
    Check Response Body Containing One Subscription element    ${subscription_expectation}    ${response['body']}

    [Teardown]  Delete Subscription  ${id}

044_02_04_endpoint /subscriptions/{subscriptionId}
    [Documentation]  Verify that on a GET HTTP request if nothing is specified on the Accept header, "application/json" is assumed (/subscriptions/{subscriptionId})

    ${id}=  Generate Random Entity Id    ${subscription_id_prefix}    
    ${response}=    Create Subscription    ${id}    ${subscription_filename}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=  Retrieve Subscription  ${id}
    Check Response Status Code  200    ${response['status']}
    Check Response Body Containing One Subscription element    ${subscription_expectation}    ${response['body']}

    [Teardown]  Delete Subscription  ${id}

044_02_05_endpoint /types/
    [Documentation]  Verify that on a GET HTTP request if nothing is specified on the Accept header, "application/json" is assumed (/types/)
    
    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${second_entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}

    Create Entity Selecting Content Type  ${building_filename}     ${first_entity_id}    ${CONTENT_TYPE_JSON}    ${ngsild_test_suite_context}
    Create Entity Selecting Content Type  ${vehicle_filename}     ${second_entity_id}    ${CONTENT_TYPE_JSON}    ${ngsild_test_suite_context}

    @{entities_ids_to_be_deleted}=  Create List   ${first_entity_id}    ${second_entity_id}

    Retrieve Entity Types   context=${EMPTY}   accept=${EMPTY}

    Check Response Status Code Set To  200
    Check Response Body Containing EntityTypeList element   ${types_expectation}

    [Teardown]  Batch Delete Entities  @{entities_ids_to_be_deleted}       teardown=True

044_02_06_endpoint /types/{type}
    [Documentation]  Verify that on a GET HTTP request if nothing is specified on the Accept header, "application/json" is assumed (/types/{type})
    
    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${second_entity_id}=     Generate Random Entity Id    ${building_id_prefix}

    Create Entity Selecting Content Type  ${building_filename}     ${first_entity_id}    ${CONTENT_TYPE_JSON}    ${ngsild_test_suite_context}
    Create Entity Selecting Content Type  ${building_filename}     ${second_entity_id}    ${CONTENT_TYPE_JSON}    ${ngsild_test_suite_context}

    @{entities_ids_to_be_deleted}=  Create List   ${first_entity_id}    ${second_entity_id}

    Retrieve Entity Type   type=Building    context=${EMPTY}   accept=${EMPTY}

    Check Response Status Code Set To  200
    Check Response Body Containing EntityTypeInfo element   ${type_expectation}

    [Teardown]  Batch Delete Entities  @{entities_ids_to_be_deleted}       teardown=True

044_02_07_endpoint /attributes/
    [Documentation]  Verify that on a GET HTTP request if nothing is specified on the Accept header, "application/json" is assumed (/attributes/)

    ${entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    Create Entity Selecting Content Type  ${building_filename}     ${entity_id}    ${CONTENT_TYPE_JSON}    ${ngsild_test_suite_context}

    Retrieve Attributes   context=${EMPTY}    accept=${EMPTY}
    Check Response Status Code Set To  200
    Check Response Body Containing AttributeList element   ${attributes_expectation}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}

044_02_08_endpoint /attributes/{attrId}
    [Documentation]  Verify that on a GET HTTP request if nothing is specified on the Accept header, "application/json" is assumed (/attributes/{attrId})
    
    ${entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    Create Entity Selecting Content Type  ${building_filename}     ${entity_id}    ${CONTENT_TYPE_JSON}    ${ngsild_test_suite_context}

    Retrieve Attribute   attribute_name=airQualityLevel     context=${ngsild_test_suite_context}     accept=${EMPTY}
    Check Response Status Code Set To  200
    Check Response Body Containing Attribute element   ${attribute_expectation}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}

044_02_09_endpoint /csourceRegistrations/
    [Documentation]  Verify that on a GET HTTP request if nothing is specified on the Accept header, "application/json" is assumed (/csourceRegistrations/)

    ${registration_id}=     Generate Random Entity Id    ${registration_id_prefix}
    ${payload}=    Load Json From File    ${EXECDIR}/data/${registration_filename}
    ${updated_payload}=    Update Value To Json    ${payload}     $..id   ${registration_id}
    ${request}    ${response}=    Create Context Source Registration With Return  ${updated_payload}
    Check Response Status Code  201    ${response['status']}

    Query Context Source Registrations      id=${registration_id}    type=${registration_type}
    Check Response Status Code Set To  200
    Check Response Body Containing One Registration element  ${registration_expectation}    ${response['body']}

    [Teardown]  Delete Context Source Registration    ${registration_id}

044_02_10_endpoint /csourceRegistrations/{registrationId}
    [Documentation]  Verify that on a GET HTTP request if nothing is specified on the Accept header, "application/json" is assumed (/csourceRegistrations/{registrationId})

    ${registration_id}=     Generate Random Entity Id    ${registration_id_prefix}
    ${payload}=    Load Json From File    ${EXECDIR}/data/${registration_filename}
    ${updated_payload}=    Update Value To Json    ${payload}     $..id   ${registration_id}
    ${request}    ${response}=    Create Context Source Registration With Return  ${updated_payload}
    Check Response Status Code  201    ${response['status']}

    Retrieve Context Source Registration  ${registration_id}
    Check Response Status Code Set To  200
    Check Response Body Containing One Registration element  ${registration_expectation}    ${response['body']}

    [Teardown]  Delete Context Source Registration    ${registration_id}

044_02_11_endpoint /csourceSubscriptions/
    [Documentation]  Verify that on a GET HTTP request if nothing is specified on the Accept header, "application/json" is assumed (/csourceSubscriptions/)

    ${subscription_id}=     Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=  Load Test Sample    ${subscription_filename}    ${subscription_id}
    Create Context Source Registration Subscription  ${subscription_payload}

    Query Context Source Registration Subscriptions 
    Check Response Status Code Set To  200
    Check Response Body Containing Subscription element     ${subscription_expectation}   ${subscription_id}

    [Teardown]  Delete Context Source Registration Subscription     ${subscription_id}

044_02_12_endpoint /csourceSubscriptions/{subscriptionId}
    [Documentation]  Verify that on a GET HTTP request if nothing is specified on the Accept header, "application/json" is assumed (/csourceSubscriptions/{subscriptionId})

    ${subscription_id}=     Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=  Load Test Sample    ${subscription_filename}    ${subscription_id}
    Create Context Source Registration Subscription  ${subscription_payload}

    Retrieve Context Source Registration Subscription  ${subscription_id}
    Check Response Status Code Set To  200
    Check Response Body Containing Subscription element     ${subscription_expectation}   ${subscription_id}

    [Teardown]  Delete Context Source Registration Subscription     ${subscription_id}

044_02_13_endpoint /temporal/entities
    [Documentation]  Verify that on a GET HTTP request if nothing is specified on the Accept header, "application/json" is assumed (/temporal/entities)

    ${temporal_entity_representation_id}=     Generate Random Entity Id    ${tea_id_prefix}
    Create Temporal Representation Of Entity  ${tea_filename}     ${temporal_entity_representation_id}

    Query Temporal Representation Of Entities   entity_types=${teatype}    timerel=after    timeAt=2020-08-01T12:05:00Z
    Check Response Status Code Set To  200
    Check Response Body Containing EntityTemporal element      ${tea_expectation}    ${temporal_entity_representation_id}

    [Teardown]  Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}

044_02_14_endpoint /temporal/entities/{entityId}
    [Documentation]  Verify that on a GET HTTP request if nothing is specified on the Accept header, "application/json" is assumed (/temporal/entities/{entityId})

    ${temporal_entity_representation_id}=     Generate Random Entity Id    ${tea_id_prefix}
    Create Temporal Representation Of Entity  ${tea_filename}     ${temporal_entity_representation_id}

    Retrieve Temporal Representation Of Entity   ${temporal_entity_representation_id}
    Check Response Status Code Set To  200
    Check Response Body Containing EntityTemporal element      ${tea_expectation}    ${temporal_entity_representation_id}

    [Teardown]  Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
