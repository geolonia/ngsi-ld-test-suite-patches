*** Keywords ***
Check Response Status Code Set To
    [Arguments]  ${expected_status}
    ${response_status}=  convert to string  ${response['status']}
    Should Be Equal  ${response_status}  ${expected_status}

Check Response Body Containing Array Of URIs set to
    [Arguments]  @{expected_entities_ids}
    Lists Should Be Equal  ${expected_entities_ids}        ${response['body']}     ignore_order=True

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

Check Response Body Containing Problem Details Element Containing Detail Element
    [Arguments]     ${response_body}
    Should Not Be Empty     ${response_body['detail']}

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