*** Variables ***
${BUILDING_ID_PREFIX}       urn:ngsi-ld:Building:
${BUS_ID_PREFIX}            urn:ngsi-ld:Bus:
${CITY_ID_PREFIX}           urn:ngsi-ld:City:
${VEHICLE_ID_PREFIX}        urn:ngsi-ld:Vehicle:


*** Keywords ***
Build Context Link
    [Arguments]    ${context}
    RETURN    <${context}>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"
