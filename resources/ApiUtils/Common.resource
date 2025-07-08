*** Settings ***
Library     String


*** Variables ***
${BUILDING_ID_PREFIX}           urn:ngsi-ld:Building:
${BUS_ID_PREFIX}                urn:ngsi-ld:Bus:
${CITY_ID_PREFIX}               urn:ngsi-ld:City:
${PARKING_ID_PREFIX}            urn:ngsi-ld:OffStreetParking:
${VEHICLE_ID_PREFIX}            urn:ngsi-ld:Vehicle:

${SUBSCRIPTION_ID_PREFIX}=      urn:ngsi-ld:Subscription:

${CSR_ID_PREFIX}=               urn:ngsi-ld:ContextSourceRegistration:


*** Keywords ***
Build Context Link
    [Arguments]    ${context}
    RETURN    <${context}>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"

Generate Random Id
    [Arguments]    ${id_prefix}

    ${random_id}=    Generate Random String    16    [NUMBERS]
    ${entity_id}=    Catenate    ${id_prefix}${random_id}
    RETURN    ${entity_id}

Generate Random Building Entity Id
    ${entity_id}=    Generate Random Id    ${BUILDING_ID_PREFIX}
    RETURN    ${entity_id}

Generate Bus Entity Id
    [Arguments]    ${id_suffix}

    ${entity_id}=    Catenate    ${BUS_ID_PREFIX}${id_suffix}
    RETURN    ${entity_id}

Generate Random Parking Entity Id
    ${entity_id}=    Generate Random Id    ${VEHICLE_ID_PREFIX}
    RETURN    ${entity_id}

Generate Random Vehicle Entity Id
    ${entity_id}=    Generate Random Id    ${PARKING_ID_PREFIX}
    RETURN    ${entity_id}

Generate Random Subscription Id
    ${entity_id}=    Generate Random Id    ${SUBSCRIPTION_ID_PREFIX}
    RETURN    ${entity_id}

Generate Random CSR Id
    ${entity_id}=    Generate Random Id    ${CSR_ID_PREFIX}
    RETURN    ${entity_id}
