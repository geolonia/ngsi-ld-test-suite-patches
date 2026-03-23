*** Settings ***
Documentation       manage a mqtt server

Library             Process
Library             MQTTLibrary


*** Variables ***
${container_name}=      ngsi-ld-test-suite-mosquitto-container


*** Keywords ***
Start Mqtt Server
    [Tags]    actor_notification-receiver
    [Arguments]    ${conf_file_name}    ${port}

    ${request} =    Set Variable
    ...    docker run -d -p ${port}:1883 -v "${CURDIR}/mosquitto/${conf_file_name}:/mosquitto/config/mosquitto.conf" -v "${CURDIR}/mosquitto/mosquitto_pwd:/mosquitto/config/mosquitto_pwd" --name "${container_name}" eclipse-mosquitto:2.0.18-openssl

    ${result} =    Run Process    ${request}    shell=yes
    IF    ${result.rc} > 0
        Log To Console    The launch of mosquitto encounter an error
        Log To Console    Check that docker is installed
        Log To Console    that the port ${port} is available
        Log To Console    and that no other container named ${container_name} is running
        Log To Console    ${result.stdout}
        Log To Console    ${result.stderr}
    END

Stop Mqtt Server
    [Tags]    actor_notification-receiver
    ${request} =    Set Variable    docker container rm -f "${container_name}"
    Run Process    ${request}    shell=yes
