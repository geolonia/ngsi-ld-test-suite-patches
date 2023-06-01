*** Settings ***
Variables       ./variables.py
Library         String


*** Keywords ***
Fetch Id From Response Location Header
    [Arguments]    ${response_headers}
    ${id}=    Fetch From Right    ${response_headers['Location']}    /
    RETURN    ${id}
