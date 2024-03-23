*** Settings ***
Library     ${EXECDIR}/libraries/assertionUtils.py
Library     ${EXECDIR}/libraries/dateTimeUtils.py
Library     RequestsLibrary
Library     Collections
Library     JSONLibrary
Library     String
Resource    ${EXECDIR}/resources/ApiUtils/ContextSourceDiscovery.resource
Resource    ${EXECDIR}/resources/ApiUtils/jsonldContext.resource


*** Variables ***
${id_regex_expr}=                           root\\['id'\\]
${instance_id_regex_expr}=                  root\\[.*\\]\\['instanceId'\\]
${notification_timestamps_regex_expr}=      root\\['last.*'\\]
${notification_endpoint_uri_regex_expr}=    root\\['endpoint'\\]\\['uri'\\]
${context_regex_expr}=                      root\\['@context'\\]
${status_regex_expr}=                       root\\['status'\\]
${lastfailure_regex_expr}=                  root\\['lastFailure'\\]
${lastNotification_regex_expr}=             root\\['lastNotification'\\]
${timesFailed_regex_expr}=                  root\\['timesFailed'\\]
${timesSent_regex_expr}=                    root\\['timesSent'\\]
${is_active_expr}=                          root\\['isActive'\\]


*** Keywords ***
Check Response Status Code
    [Arguments]    ${expected_status_code}    ${response_status_code}
    ${response_status_code}=    convert to string    ${response_status_code}
    Should Be Equal
    ...    ${expected_status_code}
    ...    ${response_status_code}
    ...    HTTP status code comparison failed with (expected, actual) ->

Check Response Body Containing Array Of URIs set to
    [Arguments]    ${expected_entities_ids}    ${response_body}
    Lists Should Be Equal    ${expected_entities_ids}    ${response_body}    ignore_order=True

Check Response Body Containing Entities URIS set to
    [Arguments]    ${expected_entities_ids}    ${response_body}
    @{response_entities_ids}=    Create List
    FOR    ${entity}    IN    @{response_body}
        Append To List    ${response_entities_ids}    ${entity['id']}
    END

    Lists Should Be Equal    ${expected_entities_ids}    ${response_entities_ids}

Check Response Body Content
    [Arguments]    ${expectation_filename}    ${response_body}    ${additional_ignored_path}=${EMPTY}
    ${entity_payload}=    Load JSON From File    ${EXECDIR}/data/entities/expectations/${expectation_filename}
    ${all_ignored_paths}=    Create List    ${instance_id_regex_expr}    ${additional_ignored_path}
    ${comparison_result}=    Compare Dictionaries Ignoring Keys
    ...    ${entity_payload}
    ...    ${response_body}
    ...    ${all_ignored_paths}
    Should Be Empty    ${comparison_result}    msg=${comparison_result.pretty()}

Check Response Headers Containing Content-Type set to
    [Arguments]    ${expected_content_type_content}    ${response_headers}
    Should Be Equal    ${response_headers['Content-Type']}    ${expected_content_type_content}

Check Response Header is Empty
    [Arguments]    ${response_headers}
    Dictionaries Should Be Equal    ${response_headers}    {}

Check Response Headers Link Not Empty
    [Arguments]    ${response_headers}
    Should Not Be Empty    ${response_headers['Link']}

Check Response Headers Link set to
    [Arguments]    ${response_headers}    ${expected_link_header}
    Should Be Equal    ${response_headers['Link']}    ${expected_link_header}

# Since Http headers names are case-insensitive (from Http specification)
# We check both Location and location headers

Check Response Headers Containing URI set to
    [Arguments]    ${expected_entity_id}    ${response_headers}

    IF    'Location' in ${response_headers}
        Should Contain
        ...    ${response_headers['Location']}
        ...    ${expected_entity_id}
        ...    ignore_order=True
    END

Check Response Headers Containing NGSILD-Results-Count Equals To
    [Arguments]    ${expected_result_count}    ${response_headers}
    Should Be Equal    ${response_headers['NGSILD-Results-Count']}    ${expected_result_count}

# Since Http headers names are case-insensitive (from Http specification)
# We check both Location and location headers

Check Response Headers ID Not Empty
    [Arguments]    ${response_headers}

    ${location_header}=    Set Variable If
    ...    'Location' in ${response_headers}
    ...    ${response_headers['Location']}
    ${id}=    Fetch From Right    ${location_header}    /
    Should Not Be Empty    ${id}
    RETURN    ${id}

Check Response Body Containing an Attribute set to
    [Arguments]    ${expected_attribute_name}    ${response_body}    ${expected_attribute_value}=${EMPTY}
    Should Not Be Empty    ${response_body['${expected_attribute_name}']}
    IF    '${expected_attribute_value}'!=''
        Should Be Equal    ${response_body['${expected_attribute_name}']}    ${expected_attribute_value}
    END

Check Response Body Containing a Boolean Attribute set to
    [Arguments]    ${expected_attribute_name}    ${response_body}    ${expected_attribute_value}
    Dictionary Should Contain Key    ${response_body}    ${expected_attribute_name}
    IF    '${expected_attribute_value}'=='True'
        Should Be True    ${response_body['${expected_attribute_name}']}
    ELSE
        IF    '${expected_attribute_value}'=='False'
            Should Not Be True    ${response_body['${expected_attribute_name}']}
        ELSE
            Fail    Unexpected boolean value, only True/False are allowed, received ${expected_attribute_value}
        END
    END

Check Response Body Containing Batch Operation Result
    [Arguments]    ${expected_batch_operation_result}    ${response_body}
    @{expected_successful_entities_ids}=    Get From Dictionary    ${expected_batch_operation_result}    success
    @{expected_failed_entities_ids}=    Get From Dictionary    ${expected_batch_operation_result}    errors
    @{response_errors}=    Get From Dictionary    ${response_body}    errors

    ${expected_failed_entities_ids_length}=    Get Length    ${expected_failed_entities_ids}
    ${response_errors_length}=    Get Length    ${response_errors}

    Lists Should Be Equal    ${expected_successful_entities_ids}    ${response_body['success']}    ignore_order=True
    Should be Equal as Integers    ${expected_failed_entities_ids_length}    ${response_errors_length}
    FOR    ${response_error}    IN    @{response_errors}
        List Should Contain Value    ${expected_failed_entities_ids}    ${response_error['entityId']}
        Should Not Be Empty    ${response_error['error']}
    END

Check Response Body Containing Entity element
    [Arguments]    ${expectation_filename}    ${entity_id}    ${response_body}    ${ignore_core_context_version}=False
    ${entity_payload}=    Load JSON From File    ${EXECDIR}/data/entities/expectations/${expectation_filename}
    ${entity}=    Update Value To JSON    ${entity_payload}    $..id    ${entity_id}
    ${comparison_result}=    Compare Dictionaries Ignoring Keys
    ...    ${entity}
    ...    ${response_body}
    ...    ${instance_id_regex_expr}
    ...    ${ignore_core_context_version}
    Should Be Empty    ${comparison_result}    msg=${comparison_result.pretty()}

Check Response Body Containing List Containing Entity Elements
    [Arguments]
    ...    ${expectation_filename}
    ...    ${entities_ids}
    ...    ${response_body}
    ...    ${ignore_core_context_version}=False
    FOR    ${entity_id}    IN    @{entities_ids}
        ${entity}=    Get Value From JSON    ${response_body}    $[?(@.id=='${entity_id}')]
        Check Response Body Containing Entity element
        ...    ${expectation_filename}
        ...    ${entity_id}
        ...    ${entity}[0]
        ...    ${ignore_core_context_version}
    END

Check Response Body Containing List Containing Entity Elements With Different Types
    [Arguments]
    ...    ${filename}
    ...    ${entities_representation_ids}
    ...    ${response_body}
    ...    ${ignore_core_context_version}=False
    ${entities_representation_payload}=    Load JSON From File    ${EXECDIR}/data/entities/expectations/${filename}
    ${index}=    Set Variable    0
    FOR    ${entity_representation_id}    IN    @{entities_representation_ids}
        ${entities_representation_payload}=    Update Value To JSON
        ...    ${entities_representation_payload}
        ...    $.[${index}]..id
        ...    ${entity_representation_id}
        ${index}=    Evaluate    ${index} + 1
    END
    ${comparison_result}=    Compare Dictionaries Ignoring Keys
    ...    ${entities_representation_payload}
    ...    ${response_body}
    ...    ${instance_id_regex_expr}
    ...    ${ignore_core_context_version}
    ...    group_by=id
    Should Be Empty    ${comparison_result}    msg=${comparison_result.pretty()}

Check Response Body Containing EntityTemporal element
    [Arguments]    ${filename}    ${temporal_entity_representation_id}    ${response_body}
    ${temporal_entity_representation_payload}=    Load JSON From File
    ...    ${EXECDIR}/data/temporalEntities/expectations/${filename}
    ${temporal_entity_representation}=    Update Value To JSON
    ...    ${temporal_entity_representation_payload}
    ...    $..id
    ...    ${temporal_entity_representation_id}
    ${comparison_result}=    Compare Dictionaries Ignoring Keys
    ...    ${temporal_entity_representation}
    ...    ${response_body}
    ...    ${instance_id_regex_expr}
    Should Be Empty    ${comparison_result}    msg=${comparison_result.pretty()}

Check Response Body Containing List Containing EntityTemporal elements
    [Arguments]    ${filename}    ${temporal_entities_representation_ids}    ${response_body}
    ${temporal_entities_representation_payload}=    Load JSON From File
    ...    ${EXECDIR}/data/temporalEntities/expectations/${filename}
    ${index}=    Set Variable    0
    FOR    ${temporal_entity_representation_id}    IN    @{temporal_entities_representation_ids}
        ${temporal_entities_representation_payload}=    Update Value To JSON
        ...    ${temporal_entities_representation_payload}
        ...    $.[${index}]..id
        ...    ${temporal_entity_representation_id}
        ${index}=    Evaluate    ${index} + 1
    END
    ${comparison_result}=    Compare Dictionaries Ignoring Keys
    ...    ${temporal_entities_representation_payload}
    ...    ${response_body}
    ...    ${instance_id_regex_expr}
    ...    group_by=id
    Should Be Empty    ${comparison_result}    msg=${comparison_result.pretty()}

Check Response Body Containing Subscription element
    [Arguments]    ${expectation_filename}    ${subscription_id}    ${response_body}
    ${subscription_payload}=    Load JSON From File    ${EXECDIR}/data/${expectation_filename}
    ${subscription}=    Update Value To JSON    ${subscription_payload}    $..id    ${subscription_id}
    ${ignored_keys}=    Create List    ${context_regex_expr}
    ${comparison_result}=    Compare Dictionaries Ignoring Keys
    ...    ${subscription}
    ...    ${response_body}
    ...    ${ignored_keys}
    Should Be Empty    ${comparison_result}    msg=${comparison_result.pretty()}

Check Response Body Containing List Containing Subscription elements
    [Arguments]    ${expectation_file_path}    ${subscription_ids}    ${response_body}
    ${subscription_payload}=    Load JSON From File    ${EXECDIR}/data/${expectation_file_path}
    ${index}=    Set Variable    0
    FOR    ${subscription_id}    IN    @{subscription_ids}
        ${subscription_payload}=    Update Value To JSON
        ...    ${subscription_payload}
        ...    $.[${index}]..id
        ...    ${subscription_id}
        ${index}=    Evaluate    ${index} + 1
    END
    ${ignored_keys}=    Create List    ${context_regex_expr}
    ${comparison_result}=    Compare Dictionaries Ignoring Keys
    ...    ${subscription_payload}
    ...    ${response_body}
    ...    ${ignored_keys}
    Should Be Empty    ${comparison_result}    msg=${comparison_result.pretty()}

# Since response body can be a json object if it contains one element
# A check on the response body type is needed

Check Response Body Containing Number Of Entities
    [Arguments]    ${expected_entity_type}    ${expected_length}    ${response_body}

    ${response_body_length}=    Get Length    ${response_body}
    ${is_list}=    Run Keyword    Evaluate    type(${response_body})==list

    IF    ${is_list}
        Should Be Equal    ${response_body_length}    ${expected_length}
    ELSE
        Should Be Equal    ${1}    ${expected_length}
    END

    FOR    ${index}    IN RANGE    ${expected_length}
        IF    ${is_list}
            Should Be Equal    ${response_body[${index}]['type']}    ${expected_entity_type}
        END
    END
    IF    ${is_list} is ${FALSE}
        Should Be Equal    ${response_body['type']}    ${expected_entity_type}
    END

Check Response Body Containing Context Source Registration element
    [Arguments]    ${expectation_filename}    ${context_source_registration_id}    ${response_body}
    ${context_source_registration_payload}=    Load JSON From File    ${EXECDIR}/data/${expectation_filename}
    ${context_source_registration}=    Update Value To JSON
    ...    ${context_source_registration_payload}
    ...    $.id
    ...    ${context_source_registration_id}
    ${ignored_keys}=    Create List    ${context_regex_expr}
    ${comparison_result}=    Compare Dictionaries Ignoring Keys
    ...    ${context_source_registration}
    ...    ${response_body}
    ...    ${ignored_keys}
    Should Be Empty    ${comparison_result}    msg=${comparison_result.pretty()}

Check Response Body Containing EntityTypeList element
    [Arguments]    ${expectation_filename}    ${response_body}
    ${entity_type_list_payload}=    Load JSON From File    ${EXECDIR}/data/${expectation_filename}
    ${ignored_keys}=    Create List    ${id_regex_expr}
    ${comparison_result}=    Compare Dictionaries Ignoring Keys
    ...    ${entity_type_list_payload}
    ...    ${response_body}
    ...    ${ignored_keys}
    Should Be Empty    ${comparison_result}    msg=${comparison_result.pretty()}

Check Response Body Containing EntityType element
    [Arguments]    ${expectation_filename}    ${response_body}
    ${entity_type_payload}=    Load JSON From File    ${EXECDIR}/data/${expectation_filename}
    ${ignored_keys}=    Create List
    ${comparison_result}=    Compare Dictionaries Ignoring Keys
    ...    ${entity_type_payload}
    ...    ${response_body}
    ...    ${ignored_keys}
    Should Be Empty    ${comparison_result}    msg=${comparison_result.pretty()}

Check Response Body Containing EntityTypeInfo element
    [Arguments]    ${expectation_filename}    ${response_body}
    ${entity_type_info_payload}=    Load JSON From File    ${EXECDIR}/data/${expectation_filename}
    ${ignored_keys}=    Create List
    ${comparison_result}=    Compare Dictionaries Ignoring Keys
    ...    ${entity_type_info_payload}
    ...    ${response_body}
    ...    ${ignored_keys}
    Should Be Empty    ${comparison_result}    msg=${comparison_result.pretty()}

Check Response Body Containing AttributeList element
    [Arguments]    ${expectation_filename}    ${response_body}
    ${attribute_list_payload}=    Load JSON From File    ${EXECDIR}/data/${expectation_filename}
    ${ignored_keys}=    Create List    ${id_regex_expr}
    ${comparison_result}=    Compare Dictionaries Ignoring Keys
    ...    ${attribute_list_payload}
    ...    ${response_body}
    ...    ${ignored_keys}
    Should Be Empty    ${comparison_result}    msg=${comparison_result.pretty()}

Check Response Body Containing Attribute element
    [Arguments]    ${expectation_filename}    ${response_body}
    ${attribute_payload}=    Load JSON From File    ${EXECDIR}/data/${expectation_filename}
    ${ignored_keys}=    Create List
    ${comparison_result}=    Compare Dictionaries Ignoring Keys
    ...    ${attribute_payload}
    ...    ${response_body}
    ...    ${ignored_keys}
    Should Be Empty    ${comparison_result}    msg=${comparison_result.pretty()}

Check Response Body Containing List Containing Context Source Registrations elements
    [Arguments]    ${expectation_file_path}    ${expected_context_source_registrations_ids}    ${response_body}
    ${expected_context_source_registrations_payload}=    Load JSON From File
    ...    ${EXECDIR}/data/${expectation_file_path}
    ${index}=    Set Variable    0
    FOR    ${expected_context_source_registration_id}    IN    @{expected_context_source_registrations_ids}
        ${expected_context_source_registrations_payload}=    Update Value To JSON
        ...    ${expected_context_source_registrations_payload}
        ...    $.[${index}].id
        ...    ${expected_context_source_registration_id}
        ${index}=    Evaluate    ${index} + 1
    END
    ${comparison_result}=    Compare Dictionaries Ignoring Keys
    ...    ${expected_context_source_registrations_payload}
    ...    ${response_body}
    ...    ${EMPTY}
    ...    group_by=id
    Should Be Empty    ${comparison_result}    msg=${comparison_result.pretty()}

Check Response Body Type When Using Session Request
    [Arguments]    ${response_body}    ${type}
    Should Be Equal    ${response_body['type']}    ${type}

Check Response Body Containing ProblemDetails Element Containing Type Element set to
    [Arguments]    ${response_body}    ${type}
    Should Be Equal    ${response_body['type']}    ${type}

Check Response Body Title When Using Session Request
    [Arguments]    ${response_body}
    Should Not Be Empty    ${response_body['title']}

Check Response Body Containing ProblemDetails Element Containing Title Element
    [Arguments]    ${response_body}
    Should Not Be Empty    ${response_body['title']}

Check Response Body Containing ProblemDetails Element
    [Arguments]    ${response_body}    ${problem_type}
    Should Not Be Empty    ${response_body['title']}
    Should Not Be Empty    ${response_body['detail']}
    Should Be String    ${response_body['title']}
    Should Be String    ${response_body['detail']}
    Should Not Be Equal    ${response_body['title']}    ${response_body['detail']}
    Should Be Equal    ${response_body['type']}    ${problem_type}

Check Response Does Not Contain Body
    [Arguments]    ${response}
    Should Not Contain    ${response}    body

Check Response Reason set to
    [Arguments]    ${response_reason}    ${reason}
    Should Be Equal    ${response_reason}    ${reason}

Check Response Kind set to
    [Arguments]    ${response}    ${kind}
    Should Be Equal    ${response['kind']}    ${kind}

Check RL Response Body Containing ProblemDetails Element Containing Type Element set to
    [Arguments]    ${response_body}    ${type}
    ${json_response_body}=    Set Variable    ${response_body}

    Should Be Equal    ${json_response_body['type']}    ${type}

Check RL Response Body Containing ProblemDetails Element Containing Title Element
    [Arguments]    ${response_body}
    ${json_response_body}=    Set Variable    ${response_body}
    Should Not Be Empty    ${json_response_body['title']}

Check JSON Value In Response Body
    [Arguments]    ${json_path_expr}    ${value_to_check}    ${response_body}
    Should Be Equal As Strings    ${response_body${json_path_expr}}    ${value_to_check}

Check JSON Value Not In Response Body
    [Arguments]    ${json_path_expr}    ${response_body}
    Should Not Have Value In Json    ${response_body}    ${json_path_expr}

Check NotificationParams
    [Arguments]    ${filename}    ${expected_additional_members}    ${response_body}

    ${expected_notification}=    Load JSON From File    ${EXECDIR}/data/${filename}
    ${ignored_keys}=    Create List    ${notification_timestamps_regex_expr}    ${notification_endpoint_uri_regex_expr}
    ${comparison_result}=    Compare Dictionaries Ignoring Keys
    ...    ${expected_notification}
    ...    ${response_body['notification']}
    ...    ${ignored_keys}
    Should Be Empty    ${comparison_result}    msg=${comparison_result.pretty()}

    FOR    ${expected_additional_member}    IN    @{expected_additional_members}
        Should Not Be Empty    ${response_body['notification']['${expected_additional_member}']}
    END

Check Pagination Prev And Next Headers
    [Arguments]    ${prev_link}    ${next_link}    ${response_headers}
    ${expected_links}=    Create List    ${prev_link}    ${next_link}
    IF    '${prev_link}'!='' and '${next_link}'!=''
        Lists Should Be Equal
        ...    ${response_headers['Link'].replace(" ", "").split(',')}
        ...    ${expected_links}
        ...    ignore_order=True
    END
    IF    '${prev_link}'!='' and '${next_link}'==''
        Should Be Equal    ${response_headers['Link']}    ${prev_link}
    END
    IF    '${prev_link}'=='' and '${next_link}'!=''
        Should Be Equal    ${response_headers['Link']}    ${next_link}
    END

Check Resource Set To
    [Arguments]    ${expected_resource}    ${response_body}    ${ignored_keys}=${None}    ${group_by}=${None}

    ${comparison_result}=    Compare Dictionaries Ignoring Keys
    ...    ${expected_resource}
    ...    ${response_body}
    ...    ${ignored_keys}
    ...    group_by=${group_by}
    Should Be Empty    ${comparison_result}    msg=${comparison_result.pretty()}

Check Created Resource Set To
    [Arguments]    ${created_resource}    ${response_body}    ${ignored_keys}=${None}

    Check Resource Set To    ${created_resource}    ${response_body}    ${ignored_keys}

Check Created Resources Set To
    [Arguments]    ${expected_resources}    ${response_body}    ${ignored_keys}=${None}

    Check Resource Set To    ${expected_resources}    ${response_body}    ${ignored_keys}    group_by=id

Check Updated Resource Set To
    [Arguments]    ${updated_resource}    ${response_body}    ${ignored_keys}=${None}

    Check Resource Set To    ${updated_resource}    ${response_body}    ${ignored_keys}

Check Updated Resources Set To
    [Arguments]    ${updated_resources}    ${response_body}    ${ignored_keys}=${None}

    Check Resource Set To    ${updated_resources}    ${response_body}    ${ignored_keys}    group_by=id

Check SUT Not Containing Resource
    [Arguments]    ${response_status}
    ${response_status_string}=    convert to string    ${response_status}
    Should Be Equal    ${response_status_string}    404

Check SUT Not Containing Resources
    [Arguments]    ${response_body}
    Should Be Empty    ${response_body}

Check Retrieving Context Source Registration
    [Arguments]    ${registration_id}    ${context}    ${accept}    ${registration_payload}
    ${response}=    Retrieve Context Source Registration
    ...    context_source_registration_id=${registration_id}
    ...    context=${context}
    ...    accept=${accept}
    ${ignored_attributes}=    Create List    ${status_regex_expr}    @context
    Check Updated Resource Set To    ${registration_payload}    ${response.json()}    ${ignored_attributes}

Check Response Body Might Contain Additional Members of the NotificationParams
    # Check the Additional Members 5.2.14.2 in the NotificationParams data structure
    [Arguments]    ${dictionary}    ${key}
    Log    Check Response Body Might Contain Additional Members of the NotificationParams
    Log    Response Body: ${dictionary}
    Log    Key: ${key}

    ${value}=    Evaluate    $dictionary.get($key)

    IF    '${value}' != '' and '${value}' != 'None'
        IF    "${key}" == "lastNotification" or "${key}" == "lastFailure" or "${key}" == "lastSuccess"
            # Need to check that there is a DateTime value
            ${type date}=    Parse Ngsild Date    ${dictionary}[${key}]
            Should Not Be Equal
            ...    ${type date}
            ...    ${None}
            ...    The Additional Member ${key} contains a value (${value}) that it is not in DateTime format
        END
        IF    "${key}" == "timesSent"
            # Need to check that there is a Integer value
            ${type int}=    Evaluate    type(${dictionary}[${key}]).__name__
            Should Be Equal
            ...    ${type int}
            ...    int
            ...    The Additonal Member ${key} contains a value (${value}) that it is not in Number format
        END
    ELSE
        Log    The key '${key}' is not present in the dictionary
    END

Check Response Body Might Contain Optional Fields
    [Arguments]    ${dictionary}    ${key}
    Log    Check Response Body Might Contain Optional Fields
    Log    Response Body: ${dictionary}
    Log    Key: ${key}

    ${value}=    Evaluate    $dictionary.get($key)

    IF    '${value}' != '' and '${value}' != 'None'
        IF    "${key}" == "expiresAt" or "${key}" == "lastUsage"
            # Need to check that there is a DateTime value
            ${type date}=    Parse Ngsild Date    ${dictionary}[${key}]
            Should Not Be Equal
            ...    ${type date}
            ...    ${None}
            ...    The Additional Member ${key} contains a value (${value}) that it is not in DateTime format
        END
        IF    "${key}" == "throttling" or "${key}" == "timeInterval" or "${key}" == "numberOfHits"
            # Need to check that there is a Integer value
            ${type int}=    Evaluate    type(${dictionary}[${key}]).__name__
            Should Be Equal
            ...    ${type int}
            ...    int
            ...    The Additonal Member ${key} contains a value (${value}) that it is not in Number format
        END
        IF    "${key}" == "isActive"
            # Need to check that there is a Boolean balue
            ${type bool}=    Evaluate    type(${dictionary}[${key}]).__name__
            Should Be Equal
            ...    ${type bool}
            ...    bool
            ...    The Additonal Member ${key} contains a value (${value}) that it is not in Boolean format
        END
        IF    "${key}" == "subscriptionName" or "${key}" == "description" or "${key}" == "q" or "${key}" == "csf" or "${key}" == "status"
            # Need to check that there is a Boolean balue
            ${type string}=    Evaluate    type(${dictionary}[${key}]).__name__
            Should Be Equal
            ...    ${type string}
            ...    str
            ...    The Additonal Member ${key} contains a value (${value}) that it is not in String format
        END
        IF    "${key}" == "extraInfo"    Log    Found "extraInfo" key
    ELSE
        Log    The key '${key}' is not present in the dictionary
    END

Check Response Body Contains DateTime Value
    [Arguments]    ${dictionary}    ${key}    ${expected value}
    Dictionary Should Contain Key    ${dictionary}    ${key}

    ${obtained value}=    Evaluate    $dictionary.get($key)
    ${date}=    Parse Ngsild Date    ${dictionary}[${key}]

    Should Not Be Equal
    ...    ${date}
    ...    ${None}
    ...    The key (${key}) contains a value (${obtained value}) that it is not in DateTime format

    Should Be Equal
    ...    ${expected value}
    ...    ${obtained value}
    ...    The expected value (${expected value}) is not the same as the obtained value (${obtained value})

Check Context Response Body Content
    [Arguments]    ${expectation_filename}    ${response_body}

    ${context_payload}=    Load JSON From File    ${EXECDIR}/data/jsonldContext/${expectation_filename}
    Dictionaries Should Be Equal    ${response_body}    ${context_payload}

Check Context Response Body Containing Detailed Information
    [Arguments]    ${response_body}    ${context_type}

    Should Not Be Empty    ${response_body['URL']}
    Should Not Be Empty    ${response_body['localId']}
    Should Not Be Empty    ${response_body['kind']}

    Should Be String    ${response_body['URL']}
    Should Be String    ${response_body['localId']}
    Should Be String    ${response_body['kind']}

    IF    $response_body['kind'] not in $ALLOWED_CONTEXT
        fail    The value of kind:"${response_body['kind']}" is not allowed
    END

    Should Be Equal    ${response_body['kind']}    ${context_type}

    # TODO: v1.8.1 change timestamp -> createdAt
    Should Not Be Empty    ${response_body['timestamp']}
    ${date}=    Parse Ngsild Date    ${response_body['timestamp']}
    Should Not Be Equal
    ...    ${date}
    ...    ${None}
    ...    The createdAt key contains a value (${response_body['timestamp']}) that it is not in DateTime format

Check Context Response Body Containing numberOfHits value
    [Arguments]    ${response_body}    ${expected_number_of_hists}

    ${value}=    Evaluate    $response_body.get('numberOfHits')

    IF    '${value}' != '' and '${value}' != 'None'
        Log    Expected number of hits: ${expected_number_of_hists}
        Log    Received number of hits: ${response_body['numberOfHits']}

        Should Be Equal As Numbers    ${response_body['numberOfHits']}    ${expected_number_of_hists}
    END

Check Context Response Kind
    [Arguments]    ${response_body}    ${context_type}

    Should Be Equal    ${response_body['kind']}    ${context_type}

Check Context Response Body Containing a list of identifiers
    [Arguments]    ${response_body}    ${expected_length}    ${list_contexts}=${EMPTY}    ${kind}=${EMPTY}

    Length Should Be
    ...    ${response_body}
    ...    ${expected_length}
    ...    msg=The length of the strings array of @contexts is not ${expected_length}

    IF    ${expected_length}==0
        Should Be Empty    ${response_body}
    ELSE
        IF    ${expected_length}==1
            ${length_list_contexts}=    Get Length    ${list_contexts}
            IF    '${kind}' == 'Cached' or ${length_list_contexts} == 0
                Should Be Equal    ${response_body[0]}    ${core_context}
            ELSE
                List Should Contain Value
                ...    ${list_contexts}
                ...    ${response_body[0]}
                ...    msg=The received @context ${response_body[0]} is not included in the list of expected @contexts: ${list_contexts}
            END
        ELSE
            IF    ${expected_length}>1
                IF    '${kind}' == ''
                    Should Be Equal    ${response_body[0]}    ${core_context}
                ELSE
                    FOR    ${index}    ${uri_context}    IN ENUMERATE    @{list_contexts}
                        Should Be Equal    ${response_body[${index}]}    ${uri_context}
                    END
                END
            END
        END
    END

Check Context Response Body Containing a list with several URLs
    [Arguments]    ${response_body}    ${expected_length}    ${list_contexts}

    Length Should Be
    ...    ${response_body}
    ...    ${expected_length}
    ...    msg=The length of the strings array of @contexts is not ${expected_length}

    Should Be Equal    ${response_body[0]}    ${core_context}

    FOR    ${index}    ${uri_context}    IN ENUMERATE    @{list_contexts}
        Log    URI: ${uri_context} index: ${index}
        ${index}=    Evaluate    ${index} + 1

        Should Be Equal    ${response_body[${index}]}    ${uri_context}
    END

Check Cached @Contexts
    [Arguments]    ${filename}

    ${entity_payload}=    Load JSON From File    ${EXECDIR}/data/jsonldContext/${filename}
    ${contexts}=    Get From Dictionary    ${entity_payload}    @context

    &{params}=    Create Dictionary
    Set To Dictionary    ${params}    details=true

    FOR    ${contextId}    IN    @{contexts}
        ${response}=    Serve a @context    ${contextId}    true
        Check Response Kind set to    ${response.json()}    Cached
    END

Check Context Detailed Information Keys
    [Arguments]    ${my_dict}

    # TODO: spec v1.8.1 timestamp -> createdAt
    ${expected_keys}=    Create List    URL    localId    kind    createdAt    lastUsage    numberOfHits    extraInfo
    ${actual_keys}=    Get Dictionary Keys    ${my_dict}

    FOR    ${key}    IN    @{expected_keys}
        Remove Values From List    ${actual_keys}    ${key}
    END

    Should Be Empty
    ...    ${actual_keys}
    ...    msg=The @context detailed information contains keys not expected: ${actual_keys}

Check Context Response Body Containing a JSONObject with details of the @contexts
    [Arguments]    ${response}    ${expected_length}    ${list_contexts}

    ${obtained_length}=    Get Length    ${response}
    Length Should Be
    ...    ${response}
    ...    ${expected_length}
    ...    msg=The expected number of @contexts was ${expected_length} but we have obtained ${obtained_length}

    FOR    ${index}    ${item}    IN ENUMERATE    @{response}
        ${URL}=    Get From Dictionary    ${item}    URL
        IF    '${URL}'=='${core_context}'
            ${context_kind}=    Set Variable    Cached
        ELSE
            ${context_kind}=    Set Variable    Hosted
        END

        # Check mandatory keys in the response (URL, localId, kind, timestamp) and their possible values
        Check Context Response Body Containing Detailed Information    ${item}    ${context_kind}

        # Check optional keys in the response (lastUsage, numberOfHits, extraInfo) and their possible values
        Check Response Body Might Contain Optional Fields    ${response}[0]    lastUsage
        Check Response Body Might Contain Optional Fields    ${response}[0]    numberOfHits
        Check Response Body Might Contain Optional Fields    ${response}[0]    extraInfo

        # Check that there is no other keys
        Check Context Detailed Information Keys    ${item}
    END

Check Context Response Body Containing a JSONObject with details of a ImplicitlyCreated @contexts
    [Arguments]    ${response}    ${expected_length}

    ${obtained_length}=    Get Length    ${response}
    Length Should Be
    ...    ${response}
    ...    ${expected_length}
    ...    msg=The expected number of @contexts was ${expected_length} but we have obtained ${obtained_length}

    # Check mandatory keys in the response (URL, localId, kind, timestamp) and their possible values
    Check Context Response Body Containing Detailed Information    ${response}[0]    ImplicitlyCreated

    # Check optional keys in the response (lastUsage, numberOfHits, extraInfo) and their possible values
    Check Response Body Might Contain Optional Fields    ${response}[0]    lastUsage
    Check Response Body Might Contain Optional Fields    ${response}[0]    numberOfHits
    Check Response Body Might Contain Optional Fields    ${response}[0]    extraInfo

    # Check that there is no other keys
    Check Context Detailed Information Keys    ${response}[0]
