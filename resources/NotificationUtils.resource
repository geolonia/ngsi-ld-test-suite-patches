*** Settings ***
Documentation  Check Notification Behaviour
Library      BuiltIn
Library      Collections
Library      HttpCtrl.Server
Library     ${EXECDIR}/libraries/assertionUtils.py
Library     ${EXECDIR}/libraries/dateTimeUtils.py

*** Variable ***
${notification_type}=  ContextSource Notfication
${date_format}=  %Y-%m-%dT%H:%M:%SZ

*** Keywords ***
Start Local Server
    #Initialize HTTP Client And Server
    Start Server        0.0.0.0   8085

Wait for notification
    [Arguments]  ${timeout}=${5}
    #HTTP server receives it and checks incoming request for correctness
    #.. "Wait For Request"
    #.... This call is blocked until HTTP request arrives or timeout.
    #.... Further detaills: https://annoviko.github.io/robotframework-httpctrl/server.html#Wait%20For%20Request
    Wait For Request    ${timeout}
    Reply By   200

Wait for notification and validate it
    [Arguments]  ${expected_subscription_id}     ${expected_context_source_registration_ids}      ${expected_trigger_reason}      ${expected_notification_data_entities}=${EMPTY}     ${timeout}=${5}
    #HTTP server receives it and checks incoming request for correctness
    #.. "Wait For Request"
    #.... This call is blocked until HTTP request arrives or timeout.
    #.... Further detaills: https://annoviko.github.io/robotframework-httpctrl/server.html#Wait%20For%20Request
    Wait For Request    ${timeout}
    Reply By   200

    ${notification_payload}=     Get Request Body
    ${notification}    Evaluate    json.loads('''${notification_payload}''')    json
    ${notification_data_length}=    Get length    ${notification}[data]
    ${expected_notification_data_entities_length}=    Get length    ${expected_notification_data_entities}
    ${expected_notification_data_length}=    Get length    ${expected_context_source_registration_ids}

    log     ${notification}
    Should Be Equal     ${notification}[type]   ${notification_type}
    Should Be Equal     ${notification}[subscriptionId]   ${expected_subscription_id}
    ${is_date}=    Is Date    ${notification}[notifiedAt]    ${date_format}
    Should Be True      ${is_date}
    ${index}=    Set Variable    0
    FOR    ${expected_context_source_registration_id}    IN    @{expected_context_source_registration_ids}
        List Should Contain Value   ${expected_context_source_registration_ids}     ${notification}[data][${index}][@id]
        ${index}=    Evaluate    ${index} + 1
    END
    Should Be Equal     '${notification_data_length}'     '${expected_notification_data_length}'
    Should Be Equal     ${notification}[triggerReason]   ${expected_trigger_reason}

    # TODO Currently we check entities information of the first CSR returned in the notification, find a way to check them all
    Run Keyword If     ${expected_notification_data_entities_length}>0       Check Notification Data Entities  ${notification}[data][0][information]    ${expected_notification_data_entities}

Wait for subscription notification and validate it
    [Arguments]  ${expected_subscription_id}  ${expected_notification_data_entities}=${EMPTY}  ${timeout}=${5}
    #HTTP server receives it and checks incoming request for correctness
    #.. "Wait For Request"
    #.... This call is blocked until HTTP request arrives or timeout.
    #.... Further detaills: https://annoviko.github.io/robotframework-httpctrl/server.html#Wait%20For%20Request
    Wait For Request    ${timeout}
    Reply By   200

    ${notification_payload}=     Get Request Body
    ${notification}    Evaluate    json.loads('''${notification_payload}''')    json
    ${notification_data_length}=    Get length    ${notification}[data]
    ${expected_notification_data_entities_length}=    Get length    ${expected_notification_data_entities}
   

    log     ${notification}
    Should Be Equal     ${notification}[type]   ${notification_type}
    Should Be Equal     ${notification}[subscriptionId]   ${expected_subscription_id}
    ${is_date}=    Is Date    ${notification}[notifiedAt]    ${date_format}
    Should Be True      ${is_date}
    ${index}=    Set Variable    0
    
    Should Be Equal     '${notification_data_length}'     '${expected_notification_data_length}'
    
    # TODO Currently we check entities information of the first CSR returned in the notification, find a way to check them all
    Run Keyword If     ${expected_notification_data_entities_length}>0       Check Notification Data Entities  ${notification}[data][0][information]    ${expected_notification_data_entities}



Wait for no notification
    [Arguments]  ${timeout}=${5}
    #HTTP server receives it and checks incoming request for correctness
    #.. "Wait For Request"
    #.... This call is blocked until HTTP request arrives or timeout.
    #.... Further detaills: https://annoviko.github.io/robotframework-httpctrl/server.html#Wait%20For%20Request
    Wait For No Request    ${timeout}

Check Notification Data Entities
    [Arguments]  ${notification_data_information}    ${expected_notification_data_entities}

    ${notification_data_entities}=      Create List
    ${index}=    Set Variable    0
    FOR    ${registration_information}    IN    @{notification_data_information}
        Append To List      ${notification_data_entities}       ${registration_information}[entities][0][type][0]
    END

    Lists Should Be Equal  ${expected_notification_data_entities}        ${notification_data_entities}     ignore_order=True

Stop Local Server
    #Terminate HTTP Server
    Stop Server
