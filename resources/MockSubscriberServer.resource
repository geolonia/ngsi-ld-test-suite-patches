*** Settings ***
Documentation  Check Notification Behaviour
Library      BuiltIn
Library      Collections
Library      HttpCtrl.Server
Library     ${EXECDIR}/libraries/assertionUtils.py
Library     ${EXECDIR}/libraries/dateTimeUtils.py

*** Variable ***
${notification_type}=  subscriber Notfication
${date_format}=  %Y-%m-%dT%H:%M:%SZ


*** Keywords ***
Start Local Server
    #Initialize HTTP Client And Server
    Start Server        0.0.0.0   8085

Wait for redirected request
    [Arguments]  ${timeout}=${5}
    #HTTP server receives it and checks incoming request for correctness
    #.. "Wait For Request"
    #.... This call is blocked until HTTP request arrives or timeout.
    #.... Further detaills: https://annoviko.github.io/robotframework-httpctrl/server.html#Wait%20For%20Request
    Wait For Request    ${timeout}
    Reply By   200

Stop Local Server
    #Terminate HTTP Server
    Stop Server
