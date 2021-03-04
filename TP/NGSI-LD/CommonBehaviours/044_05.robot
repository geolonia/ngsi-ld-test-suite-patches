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
${registration_filename}=  registration-sample.jsonld
${registration_fragment}=  registration-with-expiration-sample.jsonld

${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${vehicle_filename}=  vehicle-datasetid-attributes-sample.jsonld
${vehicle_attribute}=  speed

${tea_id_prefix}=  urn:ngsi-ld:Vehicle:
${tea_filename}=  vehicle-temporal-representation-sample.jsonld

*** comment ***
044_05_01_endpoint /subscriptions/
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header is "application/geo+json" for operations different than "Retrieve Entity" and "Query Entity" (/subscriptions/)

    ${id}=  Generate Random Entity Id    ${subscription_id_prefix}    
    ${response}=    Create Subscription    ${id}    ${subscription_filename}    ${CONTENT_TYPE_LD_JSON}    accept=${accept}
    Check Response Status Code  ${status_code}    ${response['status']}

    [Teardown]  Delete Subscription  ${id}

044_05_02_endpoint /subscriptions/{subscriptionId}
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header is "application/geo+json" for operations different than "Retrieve Entity" and "Query Entity" (/subscriptions/{subscriptionId})

    ${id}=  Generate Random Entity Id    ${subscription_id_prefix}    
    ${response}=    Create Subscription    ${id}    ${subscription_filename}    ${CONTENT_TYPE_LD_JSON}

    ${response}=  Update Subscription  ${id}     ${subscription_fragment}    ${CONTENT_TYPE_LD_JSON}    accept=${accept}
    Check Response Status Code  ${status_code}    ${response['status']}

    [Teardown]  Delete Subscription  ${id}

#044_05_03_endpoint /types/
#    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header is "application/geo+json" for operations different than "Retrieve Entity" and "Query Entity" (/types/)

#044_05_04_endpoint /types/{type}
#    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header is "application/geo+json" for operations different than "Retrieve Entity" and "Query Entity" (/types/{type})

#044_05_05_endpoint /attributes/
#    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header is "application/geo+json" for operations different than "Retrieve Entity" and "Query Entity" (/attributes/)


#044_05_06_endpoint /attributes/{attrId}
#    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header is "application/geo+json" for operations different than "Retrieve Entity" and "Query Entity" (/attributes/{attrId})

044_05_07_endpoint /csourceRegistrations/
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header is "application/geo+json" for operations different than "Retrieve Entity" and "Query Entity" (/csourceRegistrations/)

    ${registration_id}=     Generate Random Entity Id    ${registration_id_prefix}
    ${payload}=    Load Json From File    ${EXECDIR}/data/csourceRegistrations/${registration_filename}
    ${updated_payload}=    Update Value To Json    ${payload}     $..id   ${registration_id}
    ${request}    ${response}=    Create Context Source Registration With Return  ${updated_payload}    accept=${accept}
    Check Response Status Code  ${status_code}    ${response['status']}

    [Teardown]  Delete Context Source Registration    ${registration_id}



044_05_08_endpoint /csourceRegistrations/{registrationId}
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header is "application/geo+json" for operations different than "Retrieve Entity" and "Query Entity" (/csourceRegistrations/{registrationId})

    ${registration_id}=     Generate Random Entity Id    ${registration_id_prefix}
    ${payload}=    Load Json From File    ${EXECDIR}/data/csourceRegistrations/${registration_filename}
    ${updated_payload}=    Update Value To Json    ${payload}     $..id   ${registration_id}
    ${request}    ${response}=    Create Context Source Registration With Return  ${updated_payload}
    Check Response Status Code  201    ${response['status']}

    ${fragment}=    Load Json From File    ${EXECDIR}/data/csourceRegistrations/${registration_fragment}
    ${fragment_with_id}=    Update Value To Json    ${fragment}     $..id   ${registration_id}
    ${response}=    Update Context Source Registration With Return  ${registration_id}    ${fragment_with_id}    ${CONTENT_TYPE_LD_JSON}    accept=${accept}
    Check Response Status Code  ${status_code}    ${response['status']}

    [Teardown]  Delete Context Source Registration    ${registration_id}


044_05_09_endpoint /csourceSubscriptions/
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header is "application/geo+json" for operations different than "Retrieve Entity" and "Query Entity" (/csourceSubscriptions/)

    ${subscription_id}=     Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=  Load Test Sample    ${subscription_filename}    ${subscription_id}
    Create Context Source Registration Subscription  ${subscription_payload}    accept=${accept}
    Check Response Status Code Set To  ${status_code}

    [Teardown]  Delete Context Source Registration Subscription     ${subscription_id}

*** Test Cases ***
044_05_10_endpoint /csourceSubscriptions/{subscriptionId}
    [Documentation]  Verify throwing 406 HTTP status code (Not Acceptable Media Type) if the "Accept" header is "application/geo+json" for operations different than "Retrieve Entity" and "Query Entity" (/csourceSubscriptions/{subscriptionId})

    ${subscription_id}=     Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=  Load Test Sample    ${subscription_filename}    ${subscription_id}
    Create Context Source Registration Subscription  ${subscription_payload}

    ${subscription_update_fragment}=    Load Test Sample    ${subscription_fragment}
    ${response}=  Update Context Source Registration Subscription By Selecting Content Type  ${subscription_id}     ${subscription_update_fragment}    ${CONTENT_TYPE_LD_JSON}    #accept=${accept}
    Check Response Status Code  ${status_code}    ${response['status']}

    [Teardown]  Delete Context Source Registration Subscription     ${subscription_id}