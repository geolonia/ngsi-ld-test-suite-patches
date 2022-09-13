*** Settings ***
Documentation     A Notification shall be sent (as mandated by each concrete binding and including any optional endpoint.info defined by clause 5.2.22) to the endpoint specified by the endpoint.uri member of the notification structure defined by clause 5.2.14


Resource          ${EXECDIR}/resources/ApiUtils.resource
Resource          ${EXECDIR}/resources/AssertionUtils.resource
Resource          ${EXECDIR}/resources/JsonUtils.resource
Resource          ${EXECDIR}/resources/NotificationUtils.resource

Suite Setup    Before Test
Suite Teardown    After Test

*** Variable ***
${subscription_id_prefix}=    urn:ngsi-ld:Subscription:
${subscription_payload_file_path}=    subscriptions/subscription-building-entities-accept-jsonld.jsonld
${building_id_prefix}=    urn:ngsi-ld:Building:
${entity_building_filepath}=    building-simple-attributes-sample.jsonld
${fragment_filename}=    airQualityLevel-fragment.jsonld
${notification_server_send_url}=     http://${send_notification_server_host}:${send_notification_server_port}/notify

*** Keywords ***
Setup Initial Subscriptions
    ${subscription_id}=    Generate Random Entity Id    ${subscription_id_prefix}
    ${subscription_payload}=    Load Subscription Sample With Reachable Endpoint    ${subscription_payload_file_path}    ${subscription_id}    ${notification_server_send_url}
    ${subscription_payload}=    Set Entity Id In Subscription    ${subscription_payload}    ${entity_id}
    Create Subscription From Subscription Payload    ${subscription_payload}    ${CONTENT_TYPE_LD_JSON}
    Set Suite Variable    ${subscription_id}

Delete Initial Subscriptions
    Delete Subscription    ${subscription_id}

Before Test
    NotificationUtils.Start Local Server    ${notification_server_host}    ${notification_server_port}

After Test
    Delete Initial Subscriptions
    Delete Initial Entity
    Stop Local Server

Add Initial Entity
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix} 
    Create Entity    ${entity_building_filepath}    ${entity_id}
    Set Suite Variable    ${entity_id}

Delete Initial Entity
    Delete Entity by Id    ${entity_id}

*** Test Cases ***
Check that a notification is sent as JSON-LD
    [Documentation]     The Notification content shall be JSON-LD when we set endpoint.accept to 'application/ld+json'
    [Tags]    sub-notification    5_11_7    046_10

    Add Initial Entity
    Setup Initial Subscriptions

    Update Entity Attributes    ${entity_id}    ${fragment_filename}    ${CONTENT_TYPE_LD_JSON}

    Wait For Request    timeout=${10}
    Reply By   200

    ${notification_headers} =    Get Request Headers
    Dictionary Should Not Contain Key    ${notification_headers}    Link

    ${notification_payload}=     Get Request Body
    # json.loads parses the payload as json. It fails if the payload is malformed
    ${notification}    Evaluate    json.loads('''${notification_payload}''')    json
    Dictionary Should Contain Key    ${notification}[data][0]    @context


