*** Settings ***
Documentation  Check that you can query context source registrations. If present, the geoquery is matched against the GeoProperty identified in the geoquery
Resource    ${EXECDIR}/resources/ApiUtils.resource
Resource    ${EXECDIR}/resources/AssertionUtils.resource
Resource    ${EXECDIR}/resources/JsonUtils.resource

Test Template  Query Context Source Registration Matching Geoquery
Suite Setup      Setup Initial Context Source Registration
Suite Teardown      Delete Created Context Source Registration

*** Variable ***
${context_source_registration_id_prefix}=  urn:ngsi-ld:ContextSourceRegistration:
${context_source_registration_payload_file_path}=   csourceRegistrations/context-source-registration-location-sample.jsonld
${expectation_file_path}=   csourceRegistrations/expectations/context-source-registrations-037-07-expectation.json

*** Test Cases ***                        GEOREL                    GEOMETRY    COORDINATES                                                                         GEOPROPERTY         EXPECTATION_FILE_PATH
Near Point                                near;maxDistance==2000    Point       [-8.503,41.202]                                                                     ${EMPTY}            ${expectation_file_path}
    [Tags]   csr-query    5_10_2
Within Polygon                            within                    Polygon     [[-13.503,47.202],[6.541, 52.961],[20.37,44.653],[9.46,32.57],[-15.23,21.37]]       location            ${expectation_file_path}
    [Tags]   csr-query    5_10_2

*** Keywords ***
Query Context Source Registration Matching Geoquery
    [Arguments]  ${georel}     ${geometry}   ${coordinates}     ${geoproperty}  ${expectation_file_path}
    [Documentation]  Check that you can query context source registrations. If present, the geoquery is matched against the GeoProperty identified in the geoquery

    Query Context Source Registrations      context=${ngsild_test_suite_context}    type=Building   georel=${georel}    geometry=${geometry}  coordinates=${coordinates}  geoproperty=${geoproperty}

    @{expected_context_source_registration_ids}=  Create List   ${context_source_registration_id}
    Check Response Status Code Set To  200
    Check Response Body Containing List Containing Context Source Registrations elements     ${expectation_file_path}   ${expected_context_source_registration_ids}

Setup Initial Context Source Registration
    ${context_source_registration_id}=     Generate Random Entity Id    ${context_source_registration_id_prefix}
    ${context_source_registration_payload}=  Load Test Sample    ${context_source_registration_payload_file_path}    ${context_source_registration_id}

    Create Context Source Registration  ${context_source_registration_payload}

    Set Suite Variable  ${context_source_registration_id}

Delete Created Context Source Registration
    Delete Context Source Registration     ${context_source_registration_id}
