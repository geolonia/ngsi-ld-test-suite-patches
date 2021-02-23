*** Settings ***
Documentation  Mock http server for context sources
Library      HttpCtrl.Server

*** Keywords ***
Start Context Source Mock Server
    #Initialize HTTP Client And Server
    Start Server        0.0.0.0   8086

Wait for redirected request
    [Arguments]  ${timeout}=${5}
    #HTTP server receives it and checks incoming request for correctness
    #.. "Wait For Request"
    #.... This call is blocked until HTTP request arrives or timeout.
    #.... Further detaills: https://annoviko.github.io/robotframework-httpctrl/server.html#Wait%20For%20Request
    Wait For Request    ${timeout}
    Reply By   200

Stop Context Source Mock Server
    #Terminate HTTP Server
    Stop Server
