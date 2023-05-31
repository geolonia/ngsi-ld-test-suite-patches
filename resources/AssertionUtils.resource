*** Settings ***
Library     ${EXECDIR}/libraries/assertionUtils.py
Library    RequestsLibrary
Library    Collections
Library    JSONLibrary
Library    REST
Library    String

*** Variable ***
${id_regex_expr}=  root\\['id'\\]
${instance_id_regex_expr}=  root\\[.*\\]\\['instanceId'\\]
${notification_timestamps_regex_expr}=  root\\['last.*'\\]
${notification_endpoint_uri_regex_expr}=  root\\['endpoint'\\]\\['uri'\\]
${context_regex_expr}=  root\\['@context'\\]
${status_regex_expr}=  root\\['status'\\]

*** Keywords ***
Check Response Status Code
    [Arguments]  ${expected_status_code}    ${response_status_code}
    ${response_status_code}=  convert to string  ${response_status_code}
    Should Be Equal  ${expected_status_code}    ${response_status_code}

Check Response Status Code Set To
    [Arguments]  ${expected_status}
    ${response_status}=  convert to string  ${response['status']}
    Should Be Equal  ${response_status}  ${expected_status}

Check RL Response Status Code Set To
    [Arguments]  ${expected_status}
    Status Should Be    ${expected_status}     ${response}

Check Response Body Containing Array Of URIs set to
    [Arguments]  @{expected_entities_ids}
    Lists Should Be Equal  ${expected_entities_ids}        ${response['body']}     ignore_order=True

Check Response Body Content
    [Arguments]  ${expectation_filename}     ${response_body}       ${additional_ignored_path}=${EMPTY}
    ${entity_payload}=    Load Json From File    ${EXECDIR}/data/entities/expectations/${expectation_filename}
    ${all_ignored_paths}=   Create List     ${instance_id_regex_expr}   ${additional_ignored_path}
    Output  ${response_body}
    Output  ${entity_payload}
    ${comparison_result}=    Compare Dictionaries Ignoring Keys    ${entity_payload}      ${response_body}    ${all_ignored_paths}
    Should Be Empty      ${comparison_result}   msg=${comparison_result.pretty()}

Check Response Headers Containing Content-Type set to
    [Arguments]  ${response}    ${expected_content_type_content} 
    Should Be Equal  ${response['headers']['Content-Type']}    ${expected_content_type_content}

Check Response Headers Link Not Empty
    [Arguments]  ${response}
    Should Not Be Empty  ${response['headers']['Link']}

# Since Http headers names are case-insensitive (from Http specification)
# We check both Location and location headers
Check Response Headers Containing URI set to
    [Arguments]  ${expected_path}    ${expected_entity_id}    ${response}

    Run Keyword If  'Location' in ${response['headers']}  Should Be Equal  ${expected_path}${expected_entity_id}        ${response['headers']['Location']}     ignore_order=True
    Run Keyword If  'location' in ${response['headers']}  Should Be Equal  ${expected_path}${expected_entity_id}        ${response['headers']['location']}     ignore_order=True

# Since Http headers names are case-insensitive (from Http specification)
# We check both Location and location headers

Check Response Headers ID Not Empty
    [Arguments]  ${response}

    ${location_header}=     Set Variable If  'Location' in ${response['headers']}    ${response['headers']['Location']}     ${response['headers']['location']}
    ${id}=  Fetch From Right    ${location_header}  /
    Should Not Be Empty  ${id}
    [return]    ${id}

Check Response Body Containing an Attribute set to
    [Arguments]  ${expected_attribute_name}     ${expected_attribute_value}=${EMPTY}
    Should Not Be Empty     ${response['body']['${expected_attribute_name}']}
    Run Keyword If     '${expected_attribute_value}'!=''       Should Be Equal  ${response['body']['${expected_attribute_name}']}   ${expected_attribute_value}

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
    ${comparison_result}=    Compare Dictionaries Ignoring Keys    ${entity}      ${response_body}    ${instance_id_regex_expr}
    Should Be Empty      ${comparison_result}   msg=${comparison_result.pretty()}

Check Response Body Containing List Containing Entity Elements
    [Arguments]     ${expectation_filename}    ${entities_ids}    ${response_body}
    FOR    ${entity_id}    IN    @{entities_ids}
        ${entity}=     Get Value From Json    ${response_body}    $[?(@.id=='${entity_id}')]
        Check Response Body Containing Entity element    ${expectation_filename}    ${entity_id}    ${entity}[0]
    END

Check Response Body Containing List Containing Entity Elements With Different Types
    [Arguments]     ${filename}    ${entities_representation_ids}        ${response_body}
    ${entities_representation_payload}=    Load Json From File    ${EXECDIR}/data/entities/expectations/${filename}
    ${index}=    Set Variable    0
    FOR    ${entity_representation_id}    IN    @{entities_representation_ids}
        ${entities_representation_payload}=    Update Value To Json    ${entities_representation_payload}     $.[${index}]..id   ${entity_representation_id}
        ${index}=    Evaluate    ${index} + 1
    END
    ${comparison_result}=    Compare Dictionaries Ignoring Keys    ${entities_representation_payload}      ${response_body}    ${instance_id_regex_expr}   group_by=id
    Should Be Empty      ${comparison_result}   msg=${comparison_result.pretty()}

Check Response Body Containing EntityTemporal element
    [Arguments]     ${filename}    ${temporal_entity_representation_id}
    ${temporal_entity_representation_payload}=    Load Json From File    ${EXECDIR}/data/temporalEntities/expectations/${filename}
    ${temporal_entity_representation}=    Update Value To Json    ${temporal_entity_representation_payload}     $..id   ${temporal_entity_representation_id}
    ${comparison_result}=    Compare Dictionaries Ignoring Keys    ${temporal_entity_representation}      ${response['body']}    ${instance_id_regex_expr}
    Should Be Empty      ${comparison_result}   msg=${comparison_result.pretty()}

Check Response Body Containing List Containing EntityTemporal elements
    [Arguments]     ${filename}    ${temporal_entities_representation_ids}
    ${temporal_entities_representation_payload}=    Load Json From File    ${EXECDIR}/data/temporalEntities/expectations/${filename}
    ${index}=    Set Variable    0
    FOR    ${temporal_entity_representation_id}    IN    @{temporal_entities_representation_ids}
        ${temporal_entities_representation_payload}=    Update Value To Json    ${temporal_entities_representation_payload}     $.[${index}]..id   ${temporal_entity_representation_id}
        ${index}=    Evaluate    ${index} + 1
    END
    ${comparison_result}=    Compare Dictionaries Ignoring Keys    ${temporal_entities_representation_payload}      ${response['body']}    ${instance_id_regex_expr}    group_by=id
    Should Be Empty      ${comparison_result}   msg=${comparison_result.pretty()}

Check Response Body Containing Subscription element
    [Arguments]     ${expectation_filename}    ${subscription_id}
    ${subscription_payload}=    Load Json From File    ${EXECDIR}/data/${expectation_filename}
    ${subscription}=    Update Value To Json    ${subscription_payload}     $..id   ${subscription_id}
    ${ignored_keys}=    Create List     ${context_regex_expr}
    ${comparison_result}=    Compare Dictionaries Ignoring Keys    ${subscription}       ${response['body']}    ${ignored_keys}
    Should Be Empty      ${comparison_result}   msg=${comparison_result.pretty()}

Check Response Body Containing List Containing Subscription elements
    [Arguments]     ${expectation_file_path}    ${subscription_ids}
    ${subscription_payload}=    Load Json From File    ${EXECDIR}/data/${expectation_file_path}
    ${index}=    Set Variable    0
    FOR    ${subscription_id}    IN    @{subscription_ids}
        ${subscription_payload}=    Update Value To Json    ${subscription_payload}     $.[${index}]..id   ${subscription_id}
        ${index}=    Evaluate    ${index} + 1
    END
    ${ignored_keys}=    Create List     ${context_regex_expr}
    ${comparison_result}=    Compare Dictionaries Ignoring Keys    ${subscription_payload}      ${response['body']}    ${ignored_keys}
    Should Be Empty      ${comparison_result}   msg=${comparison_result.pretty()}

# Since response body can be a json object if it contains one element
# A check on the response body type is needed
Check Response Body Containing Number Of Entities
    [Arguments]     ${expected_entity_type}    ${expected_length}

    ${response_body_length}=    Get Length  ${response['body']}
    ${is_list}=    Run Keyword   Evaluate    type(${response['body']})==list

    Run Keyword If  ${is_list}  Should Be Equal  ${response_body_length}    ${expected_length}
    Run Keyword Unless  ${is_list}  Should Be Equal  ${1}    ${expected_length}

    FOR    ${index}    IN RANGE    ${expected_length}
        Run Keyword If  ${is_list}  Should Be Equal  ${response['body'][${index}]['type']}    ${expected_entity_type}
    END
    Run Keyword Unless  ${is_list}  Should Be Equal  ${response['body']['type']}    ${expected_entity_type}

Check Response Body Containing Context Source Registration element
    [Arguments]     ${expectation_filename}    ${context_source_registration_id}
    ${context_source_registration_payload}=    Load Json From File    ${EXECDIR}/data/${expectation_filename}
    ${context_source_registration}=    Update Value To Json    ${context_source_registration_payload}     $..id   ${context_source_registration_id}
    ${ignored_keys}=    Create List     ${context_regex_expr}
    ${comparison_result}=    Compare Dictionaries Ignoring Keys    ${context_source_registration}   ${response['body']}    ${ignored_keys}
    Should Be Empty      ${comparison_result}   msg=${comparison_result.pretty()}

Check Response Body Containing EntityTypeList element
    [Arguments]     ${expectation_filename}
    ${entity_type_list_payload}=    Load Json From File    ${EXECDIR}/data/${expectation_filename}
    ${ignored_keys}=    Create List     ${id_regex_expr}
    ${comparison_result}=    Compare Dictionaries Ignoring Keys    ${entity_type_list_payload}      ${response['body']}    ${ignored_keys}
    Should Be Empty      ${comparison_result}   msg=${comparison_result.pretty()}

Check Response Body Containing EntityType element
    [Arguments]     ${expectation_filename}
    ${entity_type_payload}=    Load Json From File    ${EXECDIR}/data/${expectation_filename}
    ${ignored_keys}=    Create List
    ${comparison_result}=    Compare Dictionaries Ignoring Keys    ${entity_type_payload}    ${response['body']}    ${ignored_keys}
    Should Be Empty      ${comparison_result}   msg=${comparison_result.pretty()}

Check Response Body Containing EntityTypeInfo element
    [Arguments]     ${expectation_filename}
    ${entity_type_info_payload}=    Load Json From File    ${EXECDIR}/data/${expectation_filename}
    ${ignored_keys}=    Create List
    ${comparison_result}=    Compare Dictionaries Ignoring Keys    ${entity_type_info_payload}    ${response['body']}    ${ignored_keys}
    Should Be Empty      ${comparison_result}   msg=${comparison_result.pretty()}

Check Response Body Containing AttributeList element
    [Arguments]     ${expectation_filename}
    ${attribute_list_payload}=    Load Json From File    ${EXECDIR}/data/${expectation_filename}
    ${ignored_keys}=    Create List     ${id_regex_expr}
    ${comparison_result}=    Compare Dictionaries Ignoring Keys    ${attribute_list_payload}    ${response['body']}    ${ignored_keys}
    Should Be Empty      ${comparison_result}   msg=${comparison_result.pretty()}

Check Response Body Containing Attribute element
    [Arguments]     ${expectation_filename}
    ${attribute_payload}=    Load Json From File    ${EXECDIR}/data/${expectation_filename}
    ${ignored_keys}=    Create List
    ${comparison_result}=    Compare Dictionaries Ignoring Keys    ${attribute_payload}    ${response['body']}    ${ignored_keys}
    Should Be Empty      ${comparison_result}   msg=${comparison_result.pretty()}

Check Response Body Containing List Containing Context Source Registrations elements
    [Arguments]     ${expectation_file_path}    ${expected_context_source_registrations_ids}
    ${expected_context_source_registrations_payload}=    Load Json From File    ${EXECDIR}/data/${expectation_file_path}
    ${index}=    Set Variable    0
    FOR    ${expected_context_source_registration_id}    IN    @{expected_context_source_registrations_ids}
        ${expected_context_source_registrations_payload}=    Update Value To Json    ${expected_context_source_registrations_payload}     $.[${index}]..id   ${expected_context_source_registration_id}
        ${index}=    Evaluate    ${index} + 1
    END
    ${comparison_result}=    Compare Dictionaries Ignoring Keys    ${expected_context_source_registrations_payload}    ${response['body']}    ${EMPTY}     group_by=id
    Should Be Empty      ${comparison_result}   msg=${comparison_result.pretty()}

Check Response Body Type When Using Session Request
    [Arguments]     ${response}    ${type}
    Should Be Equal     ${response['type']}    ${type}

Check Response Body Containing ProblemDetails Element Containing Type Element set to
    [Arguments]     ${response}    ${type}
    Should Be Equal     ${response['body']['type']}    ${type}

Check Response Body Title When Using Session Request
    [Arguments]     ${response}
    Should Not Be Empty     ${response['title']}

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

Check JSON Value In Response Body
    [Arguments]     ${json_path_expr}   ${value_to_check}
    Should Be Equal As Strings      ${response['body']${json_path_expr}}      ${value_to_check}

Check NotificationParams
    [Arguments]     ${filename}     ${expected_additional_members}

    ${expected_notification}=    Load Json From File    ${EXECDIR}/data/${filename}
    ${ignored_keys}=    Create List     ${notification_timestamps_regex_expr}    ${notification_endpoint_uri_regex_expr}
    ${comparison_result}=    Compare Dictionaries Ignoring Keys    ${expected_notification}      ${response['body']['notification']}    ${ignored_keys}
    Should Be Empty      ${comparison_result}   msg=${comparison_result.pretty()}

    FOR    ${expected_additional_member}    IN    @{expected_additional_members}
        Should Not Be Empty     ${response['body']['notification']['${expected_additional_member}']}
    END

Check Pagination Prev And Next Headers
    [Arguments]  ${prev_link}    ${next_link}
    ${expected_links}=   Create List     ${prev_link}    ${next_link}
    Run Keyword If     '${prev_link}'!='' and '${next_link}'!=''       Lists Should Be Equal    ${response['headers']['Link'].replace(" ", "").split(',')}    ${expected_links}   ignore_order=True
    Run Keyword If     '${prev_link}'!='' and '${next_link}'==''       Should Be Equal      ${response['headers']['Link']}    ${prev_link}
    Run Keyword If     '${prev_link}'=='' and '${next_link}'!=''       Should Be Equal      ${response['headers']['Link']}    ${next_link}

Check Response Body Containing One Subscription element
    [Arguments]     ${expectation_filename}    ${response_body}
    ${payload}=    Load Json From File    ${EXECDIR}/data/csourceSubscriptions/expectations/${expectation_filename}
    ${subscription}=    Update Value To Json    ${payload}     $..id   ${response_body['id']}
    ${comparison_result}=    Compare Dictionaries Ignoring Keys    ${subscription}      ${response_body}    ${instance_id_regex_expr}
    Should Be Empty      ${comparison_result}   msg=${comparison_result.pretty()}

Check Response Body Containing One Registration element
    [Arguments]     ${expectation_filename}    ${response_body}
    ${payload}=    Load Json From File    ${EXECDIR}/data/csourceRegistrations/expectations/${expectation_filename}
    ${registration}=    Update Value To Json    ${payload}     $..id   ${response_body['id']}
    ${comparison_result}=    Compare Dictionaries Ignoring Keys    ${registration}      ${response_body}    ${instance_id_regex_expr}
    Should Be Empty      ${comparison_result}   msg=${comparison_result.pretty()}

Check Resource Set To
    [Arguments]  ${expected_resource}       ${ignored_keys}=${None}     ${group_by}=${None}

    ${comparison_result}=    Compare Dictionaries Ignoring Keys    ${expected_resource}     ${response['body']}    ${ignored_keys}      ${group_by}
    Should Be Empty      ${comparison_result}   msg=${comparison_result.pretty()}

Check Created Resource Set To
    [Arguments]  ${created_resource}       ${ignored_keys}=${None}

    Check Resource Set To   ${created_resource}     ${ignored_keys}

Check Subscription Failed
    [Arguments]  ${subscription}       

    Should Be True ${sub}

    Check Resource Set To   ${created_resource}     ${ignored_keys}

Check Created Resources Set To
    [Arguments]  ${expected_resources}   ${ignored_keys}=${None}

    Check Resource Set To   ${expected_resources}     ${ignored_keys}       group_by=id

Check Updated Resource Set To
    [Arguments]  ${updated_resource}    ${ignored_keys}=${None}

    Check Resource Set To   ${updated_resource}     ${ignored_keys}

Check Updated Resources Set To
    [Arguments]  ${updated_resources}   ${ignored_keys}=${None}

    Check Resource Set To   ${updated_resources}     ${ignored_keys}        group_by=id

Check SUT Not Containing Resource
    ${response_status}=  convert to string  ${response['status']}
    Should Be Equal  ${response_status}  404

Check SUT Not Containing Resources
    Should Be Empty     ${response['body']}

