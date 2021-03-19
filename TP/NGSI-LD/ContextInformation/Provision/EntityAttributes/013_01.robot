*** Settings ***
Documentation   Check that you can delete an attribute from an entity
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Delete Attributes

*** Variable ***
${vehicle_id_prefix}=  urn:ngsi-ld:Vehicle:
${status_code}=  204
${filename}=  vehicle-two-datasetid-attributes-sample.jsonld
${attribute_id}=  speed

*** Test Cases ***                                                        DATASETID                                   DELETEALL       EXPECTATION_FILENAME
013_01_01_delete an attribute with the id                                 ${EMPTY}                                    false           vehicle-delete-default-speed-expectation.jsonld
013_01_02_delete an attribute with the datasetId                          urn:ngsi-ld:Property:gpsBxyz123-speed       false           vehicle-delete-datasetid-speed-expectation.jsonld
013_01_03_delete all target attribute instances with a datasetId          urn:ngsi-ld:Property:gpsBxyz123-speed       true            vehicle-delete-deleteall-speed-expectation.jsonld

*** Keywords ***
Delete Attributes
    [Arguments]  ${datasetId}    ${deleteAll}    ${expectation_filename}
    [Documentation]  Check that you can delete an attribute from an entity
    [Tags]  /entities/{entityId}/attrs/{attrId}      5_6_5

    ${entity_id}=     Generate Random Entity Id    ${vehicle_id_prefix}
    ${request}    ${response}=    Create Entity Selecting Content Type  ${filename}     ${entity_id}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Delete Entity Attributes    ${entity_id}    ${attribute_id}    ${datasetId}    ${deleteAll}
    Check Response Status Code  ${status_code}    ${response['status']}

    ${entity_expectation_payload}=    Load Test Sample   entities/expectations/${expectation_filename}    ${entity_id}
    Retrieve Entity by Id   ${entity_id}   context=${ngsild_test_suite_context}   accept=${CONTENT_TYPE_LD_JSON}
    ${ignored_attributes}=  Create List    ${status_regex_expr}    @context
    Check Updated Resource Set To     ${entity_expectation_payload}

    [Teardown]  Delete Entity by Id Returning Response   ${entity_id}