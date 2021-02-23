*** Settings ***
Documentation   Check that you cannot update a context source registration under some conditions
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Suite Setup      Setup Initial Entities

*** Variable ***
${registration_id_prefix}=  urn:ngsi-ld:Registration:
${filename}=  registration-sample.jsonld
${registration_payload_file_path}=  registration-invalid-sample.jsonld

*** Test Case ***
034_02_01_Update a context source registration by id if the Id is not present                         
  Update Context Source  ${EMPTY}    registration-with-expiration-sample.jsonld  
034_02_02_Update a context source registration by id if the Id is not a valid URI                     
  Update Context Source  invalidURI    registration-with-expiration-sample.jsonld  
034_02_03_Update a context source registration if the request body is not of the same data type       
  Update Context Source  ${valid_registration_id}    registration-different-type-sample.jsonld  
034_02_04_Update a context source registration if you attempt to remove a mandatory property          
  Update Context Source  ${valid_registration_id}    registration-invalid-structure-sample.jsonld
034_02_05_Update a context source registration if the request body is invalid 
  Update a context source registration if the request body is invalid 

*** Keywords ***
Update Context Source
    [Arguments]  ${registration_id}    ${fragment_filename}  
    [Documentation]  Check that you cannot update a context source registration under some conditions
    [Tags]  mandatory
    ${payload}=    Load Json From File    ${EXECDIR}/data/csourceRegistrations/${filename}
    ${updated_payload}=    Update Value To Json    ${payload}     $..id   ${valid_registration_id}
    ${request}    ${response}=    Create Context Source Registration With Return  ${updated_payload}
    Check Response Status Code  201    ${response['status']}

    ${fragment}=    Load Json From File    ${EXECDIR}/data/csourceRegistrations/${fragment_filename}
    ${fragment_with_id}=    Update Value To Json    ${fragment}     $..id   ${registration_id}
    ${response}=    Update Context Source Registration With Return  ${registration_id}    ${fragment_with_id}
    Check Response Status Code  400    ${response['status']}
    Check Response Body Containing ProblemDetails Element Containing Title Element     ${response}

    [Teardown]  Delete Context Source Registration    ${valid_registration_id}

Update a context source registration if the request body is invalid 
    [Documentation]  Check that you cannot update a context source registration if the request body is invalid
    [Tags]  mandatory
    ${registration_id}=     Generate Random Entity Id    ${registration_id_prefix}
    ${payload}=    Load Json From File    ${EXECDIR}/data/csourceRegistrations/${filename}
    ${updated_payload}=    Update Value To Json    ${payload}     $..id   ${registration_id}
    ${request}    ${response}=    Create Context Source Registration With Return  ${updated_payload}
    Check Response Status Code  201    ${response['status']}

    ${response}=    Update Context Source Registration Using Session  ${registration_id}    ${registration_payload_file_path}    ${CONTENT_TYPE_LD_JSON}
    Check Response Status Code  <Response [400]>    ${response}
    Check Response Body Type When Using Session Request      ${response.json()}     ${ERROR_TYPE_BAD_REQUEST_DATA}
    Check Response Body Title When Using Session Request    ${response.json()}

    [Teardown]  Delete Context Source Registration    ${registration_id}


Setup Initial Entities
    ${valid_registration_id}=     Generate Random Entity Id    ${registration_id_prefix}
    Set Suite Variable  ${valid_registration_id}