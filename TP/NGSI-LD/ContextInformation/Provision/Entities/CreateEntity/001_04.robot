*** Settings ***
Documentation   Check that the @context is obtained from a Link Header if the Content-Type header is "application/json"
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${building_id_prefix}=  urn:ngsi-ld:Building:
${filename}=    building-simple-attributes-sample.json

*** Test Case ***
Create one entity using a provided Link header with JSON content type
    [Documentation]  Check that the @context is obtained from a Link Header if the Content-Type header is "application/json"
    [Tags]  mandatory

    ${entity_id}=     Generate Random Entity Id    ${building_id_prefix}

    Create Entity Selecting Content Type  ${filename}     ${entity_id}    ${CONTENT_TYPE_JSON}   context=${ngsild_test_suite_context}

    Retrieve Entity by Id  ${entity_id}       context=${ngsild_test_suite_context}
    # Attribute should be compacted as we used the same context as provided when creating the entity
    Check Response Body Containing an Attribute set to   almostFull

    Retrieve Entity by Id  ${entity_id}
    # Attribute should not be compacted as we did not provide a context containing this term
    Check Response Body Containing an Attribute set to   https://ngsi-ld-test-suite/context#almostFull

    Delete Entity by Id     ${entity_id}
