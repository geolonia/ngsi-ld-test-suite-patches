*** Settings ***
Documentation   Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header is "application/geo+json" for operations different than "Retrieve Entity" and "Query Entity"
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${accept}=  application/geo+json
${status_code}=  406

${building_id_prefix}=  urn:ngsi-ld:Building:
${building_filename}=  building-simple-attributes-sample.jsonld
${entity_type}=  https://ngsi-ld-test-suite/context#Building

${subscription_id_prefix}=  urn:ngsi-ld:Subscription:
${subscription_filename}=  csourceSubscriptions/subscription-sample.jsonld
${subscription_fragment}=  csourceSubscriptions/fragments/subscription-update-sample.json

${registration_id_prefix}=  urn:ngsi-ld:Registration:
${registration_filename}=  context-source-registration-with-expiration-sample.jsonld
${registration_fragment}=  context-source-registration-with-expiration-expectation.json

${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${vehicle_filename}=  vehicle-simple-attributes-sample.jsonld
${vehicle_attribute}=  brandName
${vehicle_fragment}=  vehicle-brandname-fragment.jsonld

${tea_id_prefix}=  urn:ngsi-ld:Vehicle:
${tea_filename}=  vehicle-temporal-representation-sample.jsonld

*** Test Cases ***
044_05_01_endpoint create /entities/
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header is "application/geo+json" for operations different than "Retrieve Entity" and "Query Entity" (create /entities/)

    ${entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type   ${building_filename}      ${entity_id}     ${CONTENT_TYPE_LD_JSON}    accept=${accept}
    Check Response Status Code  ${status_code}    ${response['status']}

    [Teardown]    Delete Entity by Id       ${entity_id}

044_05_02_endpoint update /entities/{entityId}/attrs/{attrId}
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header is "application/geo+json" for operations different than "Retrieve Entity" and "Query Entity" (update /entities/{entityId}/attrs/{attrId})

    ${entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${vehicle_filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}
    Retrieve Entity by Id  ${entity_id}
    ${response}=    Partial Update Entity Attributes    ${entity_id}    ${vehicle_attribute}    ${vehicle_fragment}    ${CONTENT_TYPE_LD_JSON}    accept=${accept}
    Check Response Status Code  ${status_code}    ${response['status']}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}

044_05_03_endpoint create /subscriptions/
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header is "application/geo+json" for operations different than "Retrieve Entity" and "Query Entity" (create /subscriptions/)

    ${subscriptions_id}=     Generate Random Entity Id    ${subscription_id_prefix}
    ${response}=  Create Subscription  ${subscriptions_id}    ${subscription_filename}    ${CONTENT_TYPE_LD_JSON}    accept=${accept}
    Check Response Status Code  ${status_code}    ${response['status']}

    [Teardown]  Delete Subscription  ${subscriptions_id}

044_05_04_endpoint update /subscriptions/{subscriptionId}
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header is "application/geo+json" for operations different than "Retrieve Entity" and "Query Entity" (update /subscriptions/{subscriptionId})

    ${id}=  Generate Random Entity Id    ${subscription_id_prefix}    
    ${response}=    Create Subscription    ${id}    ${subscription_filename}    ${CONTENT_TYPE_LD_JSON}

    ${response}=  Update Subscription  ${id}     ${subscription_fragment}    ${CONTENT_TYPE_LD_JSON}    accept=${accept}
    Check Response Status Code  ${status_code}    ${response['status']}

    [Teardown]  Delete Subscription  ${id}

044_05_05_endpoint create /temporal/entities/
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header is "application/geo+json" for operations different than "Retrieve Entity" and "Query Entity" (create /temporal/entities/)

    ${temporal_entity_representation_id}=     Generate Random Entity Id    ${tea_id_prefix}
    ${response}=  Create Or Update Temporal Representation Of Entity Selecting Content Type  ${temporal_entity_representation_id}    ${tea_filename}     ${CONTENT_TYPE_LD_JSON}    accept=${accept}
    Check Response Status Code  ${status_code}    ${response['status']}

    [Teardown]    Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}

044_05_06_endpoint create /entityOperations/create
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header is "application/geo+json" for operations different than "Retrieve Entity" and "Query Entity" (create /entityOperations/create)

    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${second_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${first_entity}=    Load Entity    ${building_filename}      ${first_entity_id}
    ${second_entity}=    Load Entity    ${building_filename}      ${second_entity_id}
    @{entities_to_be_created}=  Create List   ${first_entity}     ${second_entity}

    Batch Create Entities   @{entities_to_be_created}    content_type=${CONTENT_TYPE_LD_JSON}    accept=${accept}

    @{expected_entities_ids}=  Create List   ${first_entity_id}     ${second_entity_id}
    Check Response Status Code Set To  ${status_code}

    [Teardown]  Batch Delete Entities  @{expected_entities_ids}

044_05_07_endpoint create /csourceRegistrations/
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header is "application/geo+json" for operations different than "Retrieve Entity" and "Query Entity" (create /csourceRegistrations/)

    ${registration_id}=     Generate Random Entity Id    ${registration_id_prefix}
    ${payload}=    Load Json From File    ${EXECDIR}/data/csourceRegistrations/${registration_filename}
    ${updated_payload}=    Update Value To Json    ${payload}     $..id   ${registration_id}
    ${request}    ${response}=    Create Context Source Registration With Return  ${updated_payload}    accept=${accept}
    Check Response Status Code  ${status_code}    ${response['status']}

    [Teardown]  Delete Context Source Registration    ${registration_id}