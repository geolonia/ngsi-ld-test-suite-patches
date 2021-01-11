*** Settings ***
Library     ${EXECDIR}/libraries/assertionUtils.py

*** Variable ***
${instance_id_regex_expr}=  root\\[.*\\]\\['instanceId'\\]

*** Keywords ***
Check Response Status Code
    [Arguments]  ${expected_status_code}    ${response_status_code}
    ${response_status_code}=  convert to string  ${response_status_code}
    Should Be Equal  ${expected_status_code}    ${response_status_code}

Check Response Status Code Set To
    [Arguments]  ${expected_status}
    ${response_status}=  convert to string  ${response['status']}
    Should Be Equal  ${response_status}  ${expected_status}

Check RL Response Status Code Set To Expected Code
    [Arguments]  ${expected_status}
    Status Should Be    ${expected_status}     ${response}

Check RL Response Status Code Set To
    [Arguments]  ${expected_status}
    Status Should Be    ${expected_status}     ${response}

Check Response Body Containing Array Of URIs set to
    [Arguments]  @{expected_entities_ids}
    Lists Should Be Equal  ${expected_entities_ids}        ${response['body']}     ignore_order=True

Check Response Body Content
    [Arguments]  ${expectation_filename}     ${response_body}
    ${entity_payload}=    Load Json From File    ${EXECDIR}/data/entities/expectations/${expectation_filename}
    ${comparaison_result}=    Compare Dictionaries Ignoring Keys    ${response_body}    ${entity_payload}      ${instance_id_regex_expr}
    Should Be True      ${comparaison_result}   msg=Entity Comparaison Failed

Check Response Headers Containing URI set to
    [Arguments]  ${expected_path}    ${expected_entity_id}    ${response}
    Should Be Equal  ${expected_path}${expected_entity_id}        ${response['headers']['Location']}     ignore_order=True

Check Response Body Containing an Attribute set to
    [Arguments]  ${expected_attribute_name}
    Should Not Be Empty     ${response['body']['${expected_attribute_name}']}

Check Response Body Details Containing Information Error
    [Arguments]  ${expected_error_message}
    Should be Equal    ${expected_error_message}     ${response['body']['details']}

Check Response Body Containing Batch Operation Result
    [Arguments]  ${expected_batch_operation_result}
    @{expected_successful_entities_ids}=    Get From Dictionary     ${expected_batch_operation_result}     success
    @{expected_failed_entities_ids}=    Get From Dictionary     ${expected_batch_operation_result}     errors
    @{response_errors}=    Get From Dictionary     ${response['body']}     errors

    ${expected_failed_entities_ids_length}=     Get Length  ${expected_failed_entities_ids}
    ${response_errors_length}=     Get Length  ${response_errors}

    Lists Should Be Equal  ${expected_successful_entities_ids}      ${response['body']['success']}     ignore_order=True
    Should be Equal as Integers  ${expected_failed_entities_ids_length}  ${response_errors_length}
    FOR    ${response_error}    IN    @{response_errors}
        List Should Contain Value       ${expected_failed_entities_ids}     ${response_error['entityId']}
        Should Not Be Empty     ${response_error['error']}
    END

Check Response Body Containing Entity element
    [Arguments]     ${expectation_filename}    ${entity_id}    ${response_body}
    ${entity_payload}=    Load Json From File    ${EXECDIR}/data/entities/expectations/${expectation_filename}
    ${entity}=    Update Value To Json    ${entity_payload}     $..id   ${entity_id}
    ${comparaison_result}=    Compare Dictionaries Ignoring Keys    ${response_body}    ${entity}      ${instance_id_regex_expr}
    Should Be True      ${comparaison_result}   msg=Entity Comparaison Failed

Check Response Body Containing List Containing Entity Elements
    [Arguments]     ${expectation_filename}    ${entities_ids}    ${response_body}
    ${index}=    Set Variable    0
    FOR    ${entity_id}    IN    @{entities_ids}
    Check Response Body Containing Entity element    ${expectation_filename}    ${entity_id}    ${response_body[${index}]}
        ${index}=    Evaluate    ${index} + 1
    END

Check Response Body Containing EntityTemporal element
    [Arguments]     ${filename}    ${temporal_entity_representation_id}
    ${temporal_entity_representation_payload}=    Load Json From File    ${EXECDIR}/data/temporalEntities/expectations/${filename}
    ${temporal_entity_representation}=    Update Value To Json    ${temporal_entity_representation_payload}     $..id   ${temporal_entity_representation_id}
    ${comparaison_result}=    Compare Dictionaries Ignoring Keys    ${response['body']}    ${temporal_entity_representation}      ${instance_id_regex_expr}
    Should Be True      ${comparaison_result}   msg=EntityTemporal Comparaison Failed

Check Response Body Containing List Containing EntityTemporal elements
    [Arguments]     ${filename}    ${temporal_entities_representation_ids}
    ${temporal_entities_representation_payload}=    Load Json From File    ${EXECDIR}/data/temporalEntities/expectations/${filename}
    ${index}=    Set Variable    0
    FOR    ${temporal_entity_representation_id}    IN    @{temporal_entities_representation_ids}
        ${temporal_entities_representation_payload}=    Update Value To Json    ${temporal_entities_representation_payload}     $.[${index}]..id   ${temporal_entity_representation_id}
        ${index}=    Evaluate    ${index} + 1
    END
    ${comparaison_result}=    Compare Dictionaries Ignoring Keys    ${response['body']}    ${temporal_entities_representation_payload}      ${instance_id_regex_expr}
    Should Be True      ${comparaison_result}   msg=EntityTemporal List Comparaison Failed

Check Response Body Containing ProblemDetails Element Containing Type Element set to
    [Arguments]     ${response}    ${type}
    Should Be Equal     ${response['body']['type']}    ${type}

Check Response Body Containing ProblemDetails Element Containing Title Element
    [Arguments]     ${response}
    Should Not Be Empty     ${response['body']['title']}

Check RL Response Body Containing ProblemDetails Element Containing Type Element set to
    [Arguments]     ${response}    ${type}
    ${json_response_body}=    Set Variable      ${response.json()}

    Should Be Equal     ${json_response_body['type']}    ${type}

Check RL Response Body Containing ProblemDetails Element Containing Title Element
    [Arguments]     ${response}
    ${json_response_body}=    Set Variable      ${response.json()}
    Should Not Be Empty     ${json_response_body['title']}

Assert response status code
    [Arguments]     ${code}
    Should Be Equal     ${response}[status]  ${code}

Check HTTP Response Status Code Is
    [Arguments]    ${expected_status}
    ${status}=    Convert To Integer    ${expected_status}
    Console
    Should Be Equal    ${response['status']}    ${status}
    Log    Status code validated

Check HTTP Response Body Json Schema Is
    [Arguments]    ${input}
    Should Contain    ${response['headers']['Content-Type']}    application/json
    ${schema} =    Catenate    SEPARATOR=    ${input}    .schema.json
    Validate Json    ${schema}    ${response['body']}
    Log    Json Schema Validation OK

Should Be Present In Json List
    [Arguments]     ${expr}   ${json_field}   ${json_value}
    Log    Check if ${json_field} is present in ${expr} with the value ${jsonvalue}
    :FOR  ${item}  IN  @{expr}
    \  Exit For Loop If    "${item['${json_field}']}" == "${json_value}"
    Log    Item found ${item}
    [return]    ${item}

Check Result Contains
    [Arguments]    ${source}    ${parameter}    ${value}
    Should Be Present In Json List    ${source}    ${parameter}    ${value}