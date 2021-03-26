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

${subscription_id_prefix}=  urn:ngsi-ld:Subscription:
${subscription_filename}=  csourceSubscriptions/subscription-sample.jsonld

*** Test Cases ***
044_04_01_endpoint get /entities/{entityId}
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header does not imply "application/json" nor "application/ld+json" (get /entities/{entityId})
    [Tags]  cb
    ${entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${building_filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

   ${request}    ${response}=    Query Entity    ${entity_id}    accept=${accept}
    Check Response Status Code  ${status_code}    ${response['status']}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}

044_04_02_endpoint get /subscriptions/{subscriptionId}
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header does not imply "application/json" nor "application/ld+json" (get /subscriptions/{subscriptionId})
    [Tags]  cb    
    ${id}=  Generate Random Entity Id    ${subscription_id_prefix}    
    ${response}=    Create Subscription    ${id}    ${subscription_filename}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${request}    ${response}=  Retrieve Subscription  ${id}    accept=${accept}
    Check Response Status Code  ${status_code}    ${response['status']}

    [Teardown]  Delete Subscription  ${id}

044_04_03_endpoint get /csourceRegistrations/
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header does not imply "application/json" nor "application/ld+json" (get /csourceRegistrations/)

    ${request}    ${response}=  Query Context Source Registrations With Return  type=Building    accept=${accept}
    Check Response Status Code  ${status_code}    ${response['status']}

044_04_04_endpoint get /csourceSubscriptions/
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header does not imply "application/json" nor "application/ld+json" (get /csourceSubscriptions/)
    [Tags]  cb    
    Query Context Source Registration Subscriptions  accept=${accept}
    Check Response Status Code Set To  ${status_code}

044_04_05_endpoint get /temporal/entities
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header does not imply "application/json" nor "application/ld+json" (get /temporal/entities)
    [Tags]  cb
    ${entity_types_to_be_retrieved}=  Catenate    SEPARATOR=,     Vehicle
    Query Temporal Representation Of Entities   entity_types=${entity_types_to_be_retrieved}    timerel=after    timeAt=2020-08-01T12:05:00Z    accept=${accept}
    Check Response Status Code Set To  ${status_code}