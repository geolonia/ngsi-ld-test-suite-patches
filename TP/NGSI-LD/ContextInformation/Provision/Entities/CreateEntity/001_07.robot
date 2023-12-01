*** Settings ***
Documentation       Check that the @context is obtained from the request payload body itself if the Content-Type header is "application/ld+json"

Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationProvision.resource
Resource            ${EXECDIR}/resources/ApiUtils/ContextInformationConsumption.resource
Resource            ${EXECDIR}/resources/AssertionUtils.resource
Resource            ${EXECDIR}/resources/JsonUtils.resource


*** Variables ***
${building_id_prefix}=      urn:ngsi-ld:Building:
${filename}=                building-simple-attributes-sample.jsonld


*** Test Cases ***
001_07_01 Create one entity using a JSON-LD @context obtained from the request payload with ld context
    [Documentation]    Check that the @context is obtained from the request payload body itself if the Content-Type header is "application/ld+json" and retrieve with ld context
    [Tags]    e-create    6_3_5
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    ${response}=    Create Entity Selecting Content Type    ${filename}    ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    ${response}=    Retrieve Entity by Id    id=${entity_id}    context=${ngsild_test_suite_context}
    # Attribute should be compacted as we used the same context as provided when creating the entity
    Check Response Body Containing an Attribute set to
    ...    expected_attribute_name=almostFull
    ...    response_body=${response.json()}
    Delete Entity by Id    ${entity_id}

001_07_02 Create one entity using a JSON-LD @context obtained from the request payload without context
    [Documentation]    Check that the @context is obtained from the request payload body itself if the Content-Type header is "application/ld+json" and retrieve without context
    [Tags]    e-create    6_3_5
    ${entity_id}=    Generate Random Entity Id    ${building_id_prefix}
    ${response}=    Create Entity Selecting Content Type    ${filename}    ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    ${response}=    Retrieve Entity by Id    id=${entity_id}
    # Attribute should not be compacted as we did not provide a context containing this term
    Check Response Body Containing an Attribute set to
    ...    expected_attribute_name=https://ngsi-ld-test-suite/context#almostFull
    ...    response_body=${response.json()}
    Delete Entity by Id    ${entity_id}
