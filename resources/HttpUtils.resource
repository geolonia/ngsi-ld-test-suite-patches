*** Settings ***
Variables       ./variables.py
Library         String


*** Keywords ***
Fetch Id From Response Location Header
    ${id}=    Fetch From Right    ${response['headers']['Location']}    /
    RETURN    ${id}
