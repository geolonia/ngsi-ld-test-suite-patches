*** Settings ***
Documentation   Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header does not imply "application/json" nor "application/ld+json"
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${accept}=  application/xml
${status_code}=  406

${building_id_prefix}=  urn:ngsi-ld:Building:
${building_filename}=  building-simple-attributes-sample.jsonld
${entity_type}=  https://ngsi-ld-test-suite/context#Building

${subscription_id_prefix}=  urn:ngsi-ld:Subscription:
${subscription_filename}=  csourceSubscriptions/subscription-sample.jsonld

${registration_id_prefix}=  urn:ngsi-ld:Registration:
${registration_filename}=  csourceRegistrations/registration-sample.jsonld

${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${vehicle_filename}=  vehicle-datasetid-attributes-sample.jsonld
${vehicle_attribute}=  speed

${tea_id_prefix}=  urn:ngsi-ld:Vehicle:
${tea_filename}=  vehicle-temporal-representation-sample.jsonld

*** Test Cases ***
044_04_01_endpoint get /entities/
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header does not imply "application/json" nor "application/ld+json" (get /entities/)

    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${building_filename}     ${first_entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}
    ${second_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${building_filename}     ${second_entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    @{entities_ids_to_be_deleted}=  Create List   ${first_entity_id}    ${second_entity_id}
    ${entities_ids_to_be_retrieved}=  Catenate    SEPARATOR=,   ${first_entity_id}    ${second_entity_id}
    @{entity_types_to_be_retrieved}=  Create List   ${entity_type}
    ${response}=    Query Entities    entity_ids=${entities_ids_to_be_retrieved}    entity_types=${entity_types_to_be_retrieved}    accept=${accept}
    Check Response Status Code  ${status_code}    ${response['status']}

    [Teardown]  Batch Delete Entities  @{entities_ids_to_be_deleted}       teardown=True


044_04_02_endpoint get /entities/{entityId}
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header does not imply "application/json" nor "application/ld+json" (get /entities/{entityId})
    
    ${entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${building_filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Query Entity    ${entity_id}    accept=${accept}
    Check Response Status Code  ${status_code}    ${response['status']}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}

044_04_03_endpoint get /subscriptions/
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header does not imply "application/json" nor "application/ld+json" (get /subscriptions/)
    
    ${id}=  Generate Random Entity Id    ${subscription_id_prefix}    
    ${response}=    Create Subscription    ${id}    ${subscription_filename}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=  Query Subscriptions    accept=${accept}
    Check Response Status Code  ${status_code}    ${response['status']}

    [Teardown]  Delete Subscription  ${id}

044_04_04_endpoint get /subscriptions/{subscriptionId}
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header does not imply "application/json" nor "application/ld+json" (get /subscriptions/{subscriptionId})
    
    ${id}=  Generate Random Entity Id    ${subscription_id_prefix}    
    ${response}=    Create Subscription    ${id}    ${subscription_filename}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=  Retrieve Subscription  ${id}    accept=${accept}
    Check Response Status Code  ${status_code}    ${response['status']}

    [Teardown]  Delete Subscription  ${id}

044_04_05_endpoint get /types/
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header does not imply "application/json" nor "application/ld+json" (get /types/)

    ${entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${building_filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=  Retrieve Entity Types With Return   ${accept}
    Check Response Status Code  ${status_code}    ${response['status']}
    
    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}

044_04_06_endpoint get /types/{type}
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header does not imply "application/json" nor "application/ld+json" (get /types/{type})
        
    ${entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${building_filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}
    
    ${response}=  Retrieve Entity Type With Return  ${entity_type}    ${accept}
    Check Response Status Code  ${status_code}    ${response['status']}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}

044_04_07_endpoint get /attributes/
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header does not imply "application/json" nor "application/ld+json" (get /attributes/)
     
    ${entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    Create Entity Selecting Content Type  ${building_filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}

    ${response}=  Retrieve Attributes With Return   ${accept}
    Check Response Status Code  ${status_code}    ${response['status']}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}

044_04_08_endpoint get /attributes/{attrId}
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header does not imply "application/json" nor "application/ld+json" (get /attributes/{attrId})
     
    ${entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    Create Entity Selecting Content Type  ${building_filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    ${response}=  Retrieve Attribute With Return  airQualityLevel     ${accept}
    Check Response Status Code  ${status_code}    ${response['status']}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}

044_04_09_endpoint get /csourceRegistrations/
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header does not imply "application/json" nor "application/ld+json" (get /csourceRegistrations/)

    Query Context Source Registrations  type=Building    accept=${accept}
    Check Response Status Code Set To  ${status_code}


044_04_10_endpoint get /csourceRegistrations/{registrationId}
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header does not imply "application/json" nor "application/ld+json" (get /csourceRegistrations/{registrationId})
    
    ${context_source_registration_id}=     Generate Random Entity Id    ${registration_id_prefix}
    ${context_source_registration_payload}=  Load Test Sample    ${registration_filename}    ${context_source_registration_id}
    Create Context Source Registration  ${context_source_registration_payload}

    
    Retrieve Context Source Registration  ${context_source_registration_id}    accept=${accept}
    Check Response Status Code Set To  ${status_code}

    [Teardown]  Delete Context Source Registration     ${context_source_registration_id}


044_04_11_endpoint get /csourceSubscriptions/
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header does not imply "application/json" nor "application/ld+json" (get /csourceSubscriptions/)
    
    Query Context Source Registration Subscriptions  accept=${accept}
    Check Response Status Code Set To  ${status_code}

044_04_12_endpoint get /csourceSubscriptions/{subscriptionId}
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header does not imply "application/json" nor "application/ld+json" (get /csourceSubscriptions/{subscriptionId})
    
    ${subscription_id}=     Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=  Load Test Sample    ${subscription_filename}    ${subscription_id}
    Create Context Source Registration Subscription  ${subscription_payload}

    Retrieve Context Source Registration Subscription  ${subscription_id}    accept=${accept}
    Check Response Status Code Set To  ${status_code}

    [Teardown]  Delete Context Source Registration Subscription     ${subscription_id}

044_04_13_endpoint get /temporal/entities
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header does not imply "application/json" nor "application/ld+json" (get /temporal/entities)
    
    @{entity_types_to_be_retrieved}=  Create List   Vehicle
    Query Temporal Representation Of Entities   entity_types=${entity_types_to_be_retrieved}    timerel=after    timeAt=2020-08-01T12:05:00Z    accept=${accept}
    Check Response Status Code Set To  ${status_code}

044_04_14_endpoint get /temporal/entities/{entityId}
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header does not imply "application/json" nor "application/ld+json" (get /temporal/entities/{entityId})
    
    ${temporal_entity_representation_id}=     Generate Random Entity Id    ${tea_id_prefix}
    Create Temporal Representation Of Entity  ${tea_filename}     ${temporal_entity_representation_id}

    Retrieve Temporal Representation Of Entity   ${temporal_entity_representation_id}    accept=${accept}
    Check Response Status Code Set To  ${status_code}

    [Teardown]  Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}