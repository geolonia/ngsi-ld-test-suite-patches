*** Settings ***
Documentation       Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json"

Resource            ${EXECDIR}/resources/ApiUtils.resource
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
044_03_01 endpoint patch /entities/{entityId}/attrs/{attrId}
    [Documentation]    Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json" (patch /entities/{entityId}/attrs/{attrId})
    [Tags]    ea-partial-update    6_3_4
    ${entity_id}=    Generate Random Entity Id    ${vehicle_id_prefix}
    ${response}=    Create Entity Selecting Content Type
    ...    ${vehicle_filename}
    ...    ${entity_id}
    ...    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Partial Update Entity Attributes
    ...    entityId=${entity_id}
    ...    attributeId=${vehicle_attribute}
    ...    fragment_filename=${vehicle_fragment}
    ...    content_type=${content_type}
    Check Response Status Code    415    ${response.status_code}
    [Teardown]    Delete Entity by Id Returning Response    ${entity_id}

044_03_02 endpoint patch /subscriptions/{subscriptionId}
    [Documentation]    Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json" (patch /subscriptions/{subscriptionId})
    [Tags]    sub-update    6_3_4
    ${id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${response}=    Create Subscription    ${id}    ${subscription_filename}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code    201    ${response.status_code}
    ${response}=    Update Subscription    ${id}    ${subscription_fragment}    ${content_type}
    Check Response Status Code    415    ${response.status_code}
    [Teardown]    Delete Subscription    ${id}

044_03_03 endpoint post /entities/
    [Documentation]    Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json" (post /entities/)
    [Tags]    e-create    6_3_4
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    ${response}=    Create Entity Selecting Content Type
    ...    ${building_filename}
    ...    ${entity_id}
    ...    ${content_type}
    Check Response Status Code    415    ${response.status_code}
    [Teardown]    Delete Entity by Id    ${entity_id}

044_03_04 endpoint post /subscriptions/
    [Documentation]    Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json" (post /subscriptions/)
    [Tags]    sub-create    6_3_4
    ${subscriptions_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${response}=    Create Subscription    ${subscriptions_id}    ${subscription_filename}    ${content_type}
    Check Response Status Code    415    ${response.status_code}
    [Teardown]    Delete Subscription    ${subscriptions_id}

044_03_05 endpoint post /entityOperations/create
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
    [Teardown]    Batch Delete Entities    @{expected_entities_ids}

044_03_06 endpoint post /temporal/entities/
    [Documentation]    Verify throwing 415 HTTP status code (Unsupported Media Type) if "Content-Type" header is not "application/json" or "application/ld+json" (post /temporal/entities/)
    [Tags]    te-create    6_3_4
    ${temporal_entity_representation_id}=    Generate Random Entity Id    ${tea_id_prefix}
    ${response}=    Create Or Update Temporal Representation Of Entity Selecting Content Type
    ...    ${temporal_entity_representation_id}
    ...    ${tea_filename}
    ...    ${content_type}
    Check Response Status Code    415    ${response.status_code}
    [Teardown]    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}
