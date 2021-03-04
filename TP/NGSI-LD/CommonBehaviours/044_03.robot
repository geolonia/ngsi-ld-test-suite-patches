*** Settings ***
Documentation   Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json"
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${vehicle_filename}=  vehicle-datasetid-attributes-sample.jsonld
${vehicle_attribute}=  speed
${vehicle_fragment}=  vehicle-fragment-empty-datasetid-sample.jsonld

${subscription_id_prefix}=  urn:ngsi-ld:Subscription:
${subscription_filename}=  csourceSubscriptions/subscription-sample.jsonld
${subscription_fragment}=  csourceSubscriptions/fragments/subscription-update-sample.jsonld

${registration_id_prefix}=  urn:ngsi-ld:Registration:
${registration_filename}=  csourceRegistrations/registration-sample.jsonld
${registration_fragment}=  csourceRegistrations/registration-with-expiration-sample.jsonld  

${tea_id_prefix}=  urn:ngsi-ld:Vehicle:
${tea_filename}=  vehicle-temporal-representation-sample.jsonld
${tea_fragment}=  vehicle-temporal-intanceid-update-sample.jsonld
${tea_attribute}=  speed
${tea_first_vehicle_payload_file}=  2020-08-vehicule-temporal-representation-sample.jsonld
${tea_second_vehicle_payload_file}=  2020-09-vehicule-temporal-representation-sample.jsonld

${building_id_prefix}=  urn:ngsi-ld:Building:
${building_filename}=  building-simple-attributes-sample.jsonld
${entity_type}=  https://ngsi-ld-test-suite/context#Building

*** Test Cases ***
044_03_01_endpoint patch /entities/{entityId}/attrs/
    [Documentation]  Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json" (patch /entities/{entityId}/attrs/)

    ${entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${vehicle_filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Update Entity Attributes    ${entity_id}    ${vehicle_fragment}    ${EMPTY}
    Check Response Status Code  415    ${response['status']}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}

044_03_02_endpoint patch /entities/{entityId}/attrs/{attrId}
    [Documentation]  Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json" (patch /entities/{entityId}/attrs/{attrId})

    ${entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${vehicle_filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Partial Update Entity Attributes    ${entity_id}    ${vehicle_attribute}    ${vehicle_fragment}    ${EMPTY}
    Check Response Status Code  415    ${response['status']}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}

044_03_03_endpoint patch /subscriptions/{subscriptionId}
    [Documentation]  Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json" (patch /subscriptions/{subscriptionId})

    ${id}=  Generate Random Entity Id  ${subscription_id_prefix}    
    ${response}=  Create Subscription  ${id}    ${subscription_filename}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=  Update Subscription  ${id}     ${subscription_fragment}    ${EMPTY}
    Check Response Status Code  415    ${response['status']}

    [Teardown]  Delete Subscription  ${id}

044_03_04_endpoint patch /csourceRegistrations/{registrationId}
    [Documentation]  Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json" (patch /csourceRegistrations/{registrationId})
    
    ${registration_id}=     Generate Random Entity Id    ${registration_id_prefix}
    ${payload}=    Load Json From File    ${EXECDIR}/data/${registration_filename}
    ${updated_payload}=    Update Value To Json    ${payload}     $..id   ${registration_id}
    ${request}    ${response}=    Create Context Source Registration With Return  ${updated_payload}
    Check Response Status Code  201    ${response['status']}

    ${response}=  Update Context Source Registration With Return  ${registration_id}     ${registration_fragment}    ${EMPTY}
    Check Response Status Code  415    ${response['status']}

    [Teardown]  Delete Context Source Registration    ${registration_id}

044_03_05_endpoint patch /csourceSubscriptions/{subscriptionId}
    [Documentation]  Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json" (patch /csourceSubscriptions/{subscriptionId})

    ${subscription_id}=     Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=  Load Test Sample    ${subscription_filename}    ${subscription_id}
    Create Context Source Registration Subscription  ${subscription_payload}

    ${subscription_update_fragment}=    Load Test Sample    ${subscription_fragment}
    ${response}=  Update Context Source Registration Subscription By Selecting Content Type  ${subscription_id}     ${subscription_update_fragment}    ${EMPTY}
    Check Response Status Code  415    ${response['status']}

    [Teardown]  Delete Context Source Registration Subscription     ${subscription_id}


044_03_06_endpoint patch /temporal/entities/{entityId}/attrs/{attrId}/{instanceId}
    [Documentation]  Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json" (patch /temporal/entities/{entityId}/attrs/{attrId}/{instanceId})

    ${temporal_entity_representation_id}=     Generate Random Entity Id    ${tea_id_prefix}
    Set Suite Variable  ${temporal_entity_representation_id}
    ${response}=  Create Or Update Temporal Representation Of Entity Selecting Content Type  ${temporal_entity_representation_id}    ${tea_filename}     ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=  Get Temporal Representation Of Entity  ${temporal_entity_representation_id}    ${CONTENT_TYPE_LD_JSON}    sysAttrs
    ${instanceId}=  Set Variable  ${response['body']['https://ngsi-ld-test-suite/context#speed'][0]['instanceId']}
    
    ${response}=  Partial Update Attribute From Temporal Entity  ${temporal_entity_representation_id}    ${tea_attribute}    ${instanceId}    ${tea_fragment}    ${EMPTY}
    Check Response Status Code  415    ${response['status']}

    [Teardown]    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}


044_03_07_endpoint post /entities/
    [Documentation]  Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json" (post /entities/)

    ${entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type   ${building_filename}      ${entity_id}     ${EMPTY}
    Check Response Status Code  415    ${response['status']}

    [Teardown]    Delete Entity by Id       ${entity_id}

044_03_08_endpoint post /entities/{entityId}/attrs/
    [Documentation]  Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json" (post /entities/{entityId}/attrs/)

    ${entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${vehicle_filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Append Entity Attributes    ${entity_id}    ${vehicle_fragment}    ${EMPTY}    ${EMPTY}
    Check Response Status Code  415    ${response['status']}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}

044_03_09_endpoint post /subscriptions/
    [Documentation]  Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json" (post /subscriptions/)

    ${subscriptions_id}=     Generate Random Entity Id    ${subscription_id_prefix}
    ${response}=  Create Subscription  ${subscriptions_id}    ${subscription_filename}    ${EMPTY}
    Check Response Status Code  415    ${response['status']}

    [Teardown]  Delete Subscription  ${subscriptions_id}

044_03_10_endpoint post /csourceRegistrations/
    [Documentation]  Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json" (post /csourceRegistrations/)

    ${registration_id}=     Generate Random Entity Id    ${registration_id_prefix}

    ${payload}=    Load Json From File    ${EXECDIR}/data/${registration_filename}
    ${updated_payload}=    Update Value To Json    ${payload}     $..id   ${registration_id}
    ${request}    ${response}=    Create Context Source Registration With Return  ${updated_payload}    content_type=${EMPTY}
    Check Response Status Code  415    ${response['status']}

    [Teardown]  Delete Context Source Registration    ${registration_id}

044_03_11_endpoint post /csourceSubscriptions/
    [Documentation]  Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json" (post /csourceSubscriptions/)

    ${subscription_id}=     Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=  Load Test Sample    ${subscription_filename}    ${subscription_id}
    ${request}    ${response}=  Create Context Source Registration Subscription With Return  ${subscription_payload}    ${EMPTY}
    Check Response Status Code  415    ${response['status']}

    [Teardown]  Delete Context Source Registration Subscription  ${subscription_id}

044_03_12_endpoint post /entityOperations/create

    [Documentation]  Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json" (post /entityOperations/create)

    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${second_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${first_entity}=    Load Entity    ${building_filename}      ${first_entity_id}
    ${second_entity}=    Load Entity    ${building_filename}      ${second_entity_id}
    @{entities_to_be_created}=  Create List   ${first_entity}     ${second_entity}

    Batch Create Entities   @{entities_to_be_created}    content_type=${EMPTY}

    @{expected_entities_ids}=  Create List   ${first_entity_id}     ${second_entity_id}
    Check Response Status Code Set To  415

    [Teardown]  Batch Delete Entities  @{expected_entities_ids}


044_03_13_endpoint post /entityOperations/upsert
    [Documentation]  Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json" (post /entityOperations/upsert)

    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${second_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${first_entity}=    Load Entity    ${building_filename}      ${first_entity_id}
    ${second_entity}=    Load Entity    ${building_filename}      ${second_entity_id}
    @{entities_to_be_upserted}=  Create List   ${first_entity}     ${second_entity}
    @{expected_entities_ids}=  Create List   ${first_entity_id}     ${second_entity_id}

    Batch Upsert Entities By Selecting Content Type   @{entities_to_be_upserted}    ${EMPTY}
    Check Response Status Code Set To  415

    [Teardown]  Batch Delete Entities       @{expected_entities_ids}

044_03_14_endpoint post /entityOperations/update
    [Documentation]  Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json" (post /entityOperations/update)

    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${second_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    Create Entity  building-simple-attributes-sample.jsonld     ${first_entity_id}
    Create Entity  building-simple-attributes-sample.jsonld     ${second_entity_id}

    ${first_entity}=    Load Entity    ${building_filename}      ${first_entity_id}
    ${second_entity}=    Load Entity    ${building_filename}      ${second_entity_id}
    @{entities_to_be_updated}=  Create List   ${first_entity}     ${second_entity}
    @{entities_ids_to_be_deleted}=  Create List   ${first_entity_id}     ${second_entity_id}

    Batch Update Entities   @{entities_to_be_updated}    ${EMPTY}
    Check Response Status Code Set To  415

    [Teardown]  Batch Delete Entities  @{entities_ids_to_be_deleted}       teardown=True


044_03_15_endpoint post /entityOperations/delete
    [Documentation]  Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json" (post /entityOperations/delete)

    ${first_entity_id}=     Generate Random Entity Id    ${id_prefix}
    ${second_entity_id}=     Generate Random Entity Id    ${id_prefix}
    Create Entity  ${building_filename}    ${first_entity_id}
    Create Entity  ${building_filename}     ${second_entity_id}

    @{entities_ids_to_be_deleted}=  Create List   ${first_entity_id}     ${second_entity_id}
    Batch Delete Entities By Selecting Content Type  @{entities_ids_to_be_deleted}    ${EMPTY}
    Check Response Status Code Set To  415

044_03_16_endpoint post /entityOperations/query
    [Documentation]  Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json" (post /entityOperations/query)

    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${building_filename}     ${first_entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}
    ${second_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${building_filename}     ${second_entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}
    Query Entity    ${first_entity_id}    ${CONTENT_TYPE_LD_JSON}
    @{entities_ids_to_be_deleted}=  Create List   ${first_entity_id}    ${second_entity_id}
    ${entities_ids_to_be_retrieved}=  Catenate    SEPARATOR=,   ${first_entity_id}    ${second_entity_id}
    @{entity_types_to_be_retrieved}=  Create List   ${entity_type}
    ${response}=    Query Entities Via POST    entity_ids=${entities_ids_to_be_retrieved}    entity_types=${entity_types_to_be_retrieved}     content_type=${EMPTY}
    Check Response Status Code  415    ${response['status']}

    [Teardown]  Batch Delete Entities  @{entities_ids_to_be_deleted}       teardown=True

044_03_17_endpoint post /temporal/entities/
    [Documentation]  Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json" (post /temporal/entities/)

    ${temporal_entity_representation_id}=     Generate Random Entity Id    ${tea_id_prefix}
    ${response}=  Create Or Update Temporal Representation Of Entity Selecting Content Type  ${temporal_entity_representation_id}    ${tea_filename}     ${EMPTY}
    Check Response Status Code  415    ${response['status']}

    [Teardown]    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}

044_03_18_endpoint post /temporal/entityOperations/query
    [Documentation]  Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json" (post /temporal/entityOperations/query)

    ${first_temporal_entity_representation_id}=     Generate Random Entity Id    ${tea_id_prefix}
    ${second_temporal_entity_representation_id}=     Generate Random Entity Id    ${tea_id_prefix}
    Create Temporal Representation Of Entity  ${tea_first_vehicle_payload_file}     ${first_temporal_entity_representation_id}
    Create Temporal Representation Of Entity  ${tea_second_vehicle_payload_file}     ${second_temporal_entity_representation_id}
    @{temporal_entity_representation_ids}=  Create List  ${first_temporal_entity_representation_id}    ${second_temporal_entity_representation_id}

    Query Temporal Representation Of Entities Via Post  entity-operations-after-query.jsonld     ${EMPTY}
    Check Response Status Code  415    ${response['status']}

    [Teardown]  Delete Several Temporal Representations Of Entities  @{temporal_entity_representation_ids}