*** Settings ***
Documentation   Verify throwing 503 – LDContextNotAvaliable error if remote JSON-LD @context cannot be retrieved 
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

*** Variable ***
${expected_status_code}=  503

${building_id_prefix}=  urn:ngsi-ld:Building:
${building_filename}=  building-unretrievable-context-sample.jsonld 

${subscription_id_prefix}=  urn:ngsi-ld:Subscription:
${subscription_filename}=  subscriptions/subscription-unretrievable-context-sample.jsonld

${tea_id_prefix}=  urn:ngsi-ld:Vehicle:
${tea_filename}=  bus-temporal-representation-unretrievable-context-sample.jsonld

${registration_id_prefix}=  urn:ngsi-ld:Registration:
${registration_filename}=  csourceRegistrations/context-source-registration-unretrievable-context-sample.jsonld   

*** Test Cases *** 
043_01 Create entity
    [Documentation]  Verify throwing 503 – LDContextNotAvaliable error if remote JSON-LD @context cannot be retrieved (Create entity)
    [Tags]  e-create    5_2_2

    ${entity_id}=  Generate Random Entity Id    ${building_id_prefix}    
    ${request}    ${response}=    Create Entity Selecting Content Type   ${building_filename}      ${entity_id}     ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  ${expected_status_code}    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_LD_CONTEXT_NOT_AVAILABLE}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}

    [Teardown]  Delete Entity by Id  ${entity_id}

043_02 Create subscription
    [Documentation]  Verify throwing 503 – LDContextNotAvaliable error if remote JSON-LD @context cannot be retrieved (Create subscription)
    [Tags]  sub-create    5_2_2

    ${subscription_id}=  Generate Random Entity Id    ${subscription_id_prefix}    
    ${response}=    Create Subscription    ${subscription_id}    ${subscription_filename}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  ${expected_status_code}    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_LD_CONTEXT_NOT_AVAILABLE}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}

    [Teardown]  Delete Subscription  ${subscription_id}

043_03 Create Temporal Representation of Entities
    [Documentation]  Verify throwing 503 – LDContextNotAvaliable error if remote JSON-LD @context cannot be retrieved (Create Temporal Representation of Entities)
    [Tags]  te-create    5_2_2

    ${temporal_entity_representation_id}=     Generate Random Entity Id    ${tea_id_prefix}
    ${response}=  Create Or Update Temporal Representation Of Entity Selecting Content Type  ${temporal_entity_representation_id}    ${tea_filename}     ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  ${expected_status_code}    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_LD_CONTEXT_NOT_AVAILABLE}
    Check Response Body Containing ProblemDetails Element Containing Title Element    ${response}

    [Teardown]  Delete Temporal Representation Of Entity    ${temporal_entity_representation_id}

043_04 Batch entity create
    [Documentation]  Verify throwing 503 – LDContextNotAvaliable error if remote JSON-LD @context cannot be retrieved (Batch entity create)
    [Tags]  be-create    5_2_2

    ${first_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${second_entity_id}=     Generate Random Entity Id    ${building_id_prefix}
    ${first_entity}=    Load Entity    ${building_filename}      ${first_entity_id}
    ${second_entity}=    Load Entity    ${building_filename}      ${second_entity_id}
    @{entities_to_be_created}=  Create List   ${first_entity}     ${second_entity}

    Batch Create Entities   @{entities_to_be_created}    content_type=${CONTENT_TYPE_LD_JSON}
    Check Response Status Code Set To  ${expected_status_code}
    Check RL Response Body Containing ProblemDetails Element Containing Type Element set to      ${response}     ${ERROR_TYPE_LD_CONTEXT_NOT_AVAILABLE}
    Check RL Response Body Containing ProblemDetails Element Containing Title Element    ${response}

    [Teardown]  Batch Delete Entities  @{entities_to_be_created}

043_05 Create context source registration
    [Documentation]  Verify throwing 503 – LDContextNotAvaliable error if remote JSON-LD @context cannot be retrieved (Create context source registration)
    [Tags]  csr-create    5_2_2
    
    ${registration_id_prefix}=     Generate Random Entity Id    ${registration_id_prefix}

    ${payload}=    Load Json From File    ${EXECDIR}/data/${registration_filename}
    ${updated_payload}=    Update Value To Json    ${payload}     $..id   ${registration_id_prefix}
    ${request}    ${response}=    Create Context Source Registration With Return  ${updated_payload}
    Check Response Status Code  ${expected_status_code}    ${response['status']}
    Check Response Headers Containing URI set to    ${request['path']}/    ${registration_id}    ${response}

    [Teardown]  Delete Context Source Registration    ${registration_id_prefix}