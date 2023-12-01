*** Settings ***
Documentation       Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json"

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationSubscription.resource
Resource            ${EXECDIR}/resources/ApiUtils/TemporalContextInformationProvision.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource


*** Variables ***
${vehicle_id_prefix}=           urn:ngsi-ld:Vehicle:
${vehicle_filename}=            vehicle-simple-attributes-sample.jsonld
${vehicle_attribute}=           speed
${vehicle_fragment}=            vehicle-brandname-fragment.jsonld
${subscription_id_prefix}=      urn:ngsi-ld:Subscription:
${subscription_filename}=       csourceSubscriptions/subscription-sample.jsonld
${subscription_fragment}=       csourceSubscriptions/fragments/subscription-update-sample.jsonld
${tea_id_prefix}=               urn:ngsi-ld:Vehicle:
${tea_filename}=                vehicle-temporal-representation-sample.jsonld
${building_id_prefix}=          urn:ngsi-ld:Building:
${building_filename}=           building-simple-attributes-sample.jsonld
${content_type}=                application/xml


*** Test Cases ***
048_01_01 Endpoint patch /entities/{entityId}/attrs/{attrId}
    [Documentation]    Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json" (patch /entities/{entityId}/attrs/{attrId})
    [Tags]    ea-partial-update    6_3_4
    ${entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    ${response}=    Partial Update Entity Attributes
    ...    entityId=${entity_id}
    ...    attributeId=${vehicle_attribute}
    ...    fragment_filename=${vehicle_fragment}
    ...    content_type=${content_type}
    Check Response Status Code    415    ${response.status_code}
    [Teardown]    Delete Entity by Id Returning Response    ${entity_id}

048_01_02 Endpoint patch /subscriptions/{subscriptionId}
    [Documentation]    Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json" (patch /subscriptions/{subscriptionId})
    [Tags]    sub-update    6_3_4
    ${id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${response}=    Update Subscription    ${id}    ${subscription_fragment}    ${content_type}
    Check Response Status Code    415    ${response.status_code}
    [Teardown]    Delete Subscription    ${id}

048_01_03 Endpoint post /entities/
    [Documentation]    Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json" (post /entities/)
    [Tags]    e-create    6_3_4
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    ${response}=    Create Entity Selecting Content Type
    ...    ${building_filename}
    ...    ${entity_id}
    ...    ${content_type}
    Check Response Status Code    415    ${response.status_code}
    [Teardown]    Delete Entity by Id    ${entity_id}

048_01_04 Endpoint post /subscriptions/
    [Documentation]    Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json" (post /subscriptions/)
    [Tags]    sub-create    6_3_4
    ${subscriptions_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${response}=    Create Subscription    ${subscriptions_id}    ${subscription_filename}    ${content_type}
    Check Response Status Code    415    ${response.status_code}
    [Teardown]    Delete Subscription    ${subscriptions_id}

048_01_05 Endpoint post /entityOperations/create
    [Documentation]    Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json" (post /entityOperations/create)
    [Tags]    be-create    6_3_4
    ${first_entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    ${second_entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    ${first_entity}=    Load Entity    ${building_filename}    ${first_entity_id}
    ${second_entity}=    Load Entity    ${building_filename}    ${second_entity_id}
    @{entities_to_be_created}=    Create List    ${first_entity}    ${second_entity}
    ${response}=    Batch Create Entities    @{entities_to_be_created}    content_type=${content_type}
    @{expected_entities_ids}=    Create List    ${first_entity_id}    ${second_entity_id}
    Check Response Status Code    415    ${response.status_code}
    [Teardown]    Batch Delete Entities    entities_ids_to_be_deleted=@{expected_entities_ids}

048_01_06 Endpoint post /temporal/entities/
    [Documentation]    Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json" (post /temporal/entities/)
    [Tags]    te-create    6_3_4
    ${temporal_entity_representation_id}=    Generate Random Entity Id    ${tea_id_prefix}
    ${response}=    Create Or Update Temporal Representation Of Entity Selecting Content Type
    ...    temporal_entity_representation_id=${temporal_entity_representation_id}
    ...    filename=${tea_filename}
    ...    content_type=${content_type}
    Check Response Status Code    415    ${response.status_code}
    [Teardown]    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
