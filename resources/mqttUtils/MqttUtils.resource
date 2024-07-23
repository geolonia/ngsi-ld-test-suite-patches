*** Settings ***
Documentation       manage a mqtt server

Library             Process
Library             MQTTLibrary


*** Variables ***
${container_name}=      ngsi-ld-test-suite-mosquitto-container


*** Keywords ***
Start Mqtt Server
    [Arguments]    ${conf_file_name}    ${port}
    ${request} =    Set Variable
    ...    docker run -d -p ${port}:1883 -v "${CURDIR}/mosquitto/${conf_file_name}:/mosquitto/config/mosquitto.conf" -v "${CURDIR}/mosquitto/mosquitto_pwd:/mosquitto/config/mosquitto_pwd" --name "${container_name}" eclipse-mosquitto:2.0.18-openssl

    ${result} =    Run Process    ${request}    shell=yes
    IF    ${result.rc} > 0
        Log    The launch of mosquitto encount an error
        Log    Check that docker is installed
        Log    that the port ${port} is available
        Log    and that no other container named ${container_name} is running
        Log    ${result.stdout}
        Log    ${result.stderr}
    END

Stop Mqtt Server
    ${request} =    Set Variable    docker container rm -f "${container_name}"
    Run Process    ${request}    shell=yes
