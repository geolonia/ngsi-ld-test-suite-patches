from http import HTTPStatus


class Checks:
    def __init__(self):
        self.checks = {
            'Check Response Status Code':
                Checks.check_response_status_code,
            'Check Response Body Containing Array Of URIs set to':
                Checks.check_response_body_containing_array_of_uris_set_to,
            'Check Created Resources Set To':
                Checks.check_created_resources_set_to,
            'Check Response Headers Containing Content-Type set to':
                Checks.check_response_headers_containing_content_type_set_to,
            'Check Response Headers Link Not Empty':
                Checks.check_response_headers_link_not_empty,
            'Check Response Headers Containing URI set to':
                Checks.check_response_headers_containing_uri_set_to,
            'Check Response Headers ID Not Empty':
                Checks.check_response_headers_id_not_empty,
            'Check Response Body Containing an Attribute set to':
                Checks.check_response_body_containing_an_attribute_set_to,
            'Check Response Body Containing Entity element':
                Checks.check_response_body_containing_entity_element,
            'Check Response Body Containing List Containing Entity Elements':
                Checks.check_response_body_containing_list_containing_entity_elements,
            'Check Response Body Containing List Containing Entity Elements With Different Types':
                Checks.check_response_body_containing_list_containing_entity_elements_with_different_types,
            'Check Response Body Containing EntityTemporal element':
                Checks.check_response_body_containing_entitytemporal_element,
            'Check Response Body Containing List Containing EntityTemporal elements':
                Checks.check_response_body_containing_list_containing_entitytemporal_elements,
            'Check Response Body Containing Subscription element':
                Checks.check_response_body_containing_subscription_element,
            'Check Response Body Containing List Containing Subscription elements':
                Checks.check_response_body_containing_list_containing_subscription_elements,
            'Check Response Body Containing Number Of Entities':
                Checks.check_response_body_containing_number_of_entities,
            'Check Response Body Containing Context Source Registration element':
                Checks.check_response_body_containing_context_source_registration_element,
            'Check Response Body Containing EntityTypeList element':
                Checks.check_response_body_containing_entitytypelist_element,
            'Check Response Body Containing EntityType element':
                Checks.check_response_body_containing_entitytype_element,
            'Check Response Body Containing EntityTypeInfo element':
                Checks.check_response_body_containing_entitytypeinfo_element,
            'Check Response Body Containing AttributeList element':
                Checks.check_response_body_containing_attributelist_element,
            'Check Response Body Containing Attribute element':
                Checks.check_response_body_containing_attribute_element,
            'Check Response Body Containing List Containing Context Source Registrations elements':
                Checks.check_response_body_containing_list_containing_context_source_registrations_elements,
            'Check Response Body Type When Using Session Request':
                Checks.check_response_body_type_when_using_session_request,
            'Check Response Body Containing ProblemDetails Element Containing Type Element set to':
                Checks.check_response_body_containing_problemdetails_element_containing_type_element_set_to,
            'Check Response Body Title When Using Session Request':
                Checks.check_response_body_title_when_using_session_request,
            'Check Response Body Containing ProblemDetails Element Containing Title Element':
                Checks.check_response_body_containing_problemdetails_element_containing_title_element,
            'Check RL Response Body Containing ProblemDetails Element Containing Type Element set to':
                Checks.check_rl_response_body_containing_problemdetails_element_containing_type_element_set_to,
            'Check RL Response Body Containing ProblemDetails Element Containing Title Element':
                Checks.check_rl_response_body_containing_problemdetails_element_containing_title_element,
            'Check JSON Value In Response Body':
                Checks.check_json_value_in_response_body,
            'Check Pagination Prev And Next Headers':
                Checks.check_pagination_prev_and_next_headers,
            'Check Created Resource Set To':
                Checks.check_created_resource_set_to,
            'Check Updated Resource Set To':
                Checks.check_updated_resource_set_to,
            'Check SUT Not Containing Resource':
                Checks.check_sut_not_containing_resource
        }

        self.args = {
            'Check Response Body Type When Using Session Request': [2],
            'Check Response Body Containing ProblemDetails Element Containing Type Element set to': [2],
            'Check RL Response Body Containing ProblemDetails Element Containing Type Element set to': [2],
            'Check JSON Value In Response Body': [1, 2],
            'Check Pagination Prev And Next Headers': [2, 3],
            'Check SUT Not Containing Resource': [1]
        }

    @staticmethod
    def check_response_status_code(kwargs: list) -> str:
        if "status_code" in kwargs:
            status_code = kwargs['status_code']
            return f'Response Status Code set to {status_code} ({HTTPStatus(status_code).phrase})'
        else:
            raise Exception(f'ERROR, Expected status_code parameter but received: {kwargs}')

    @staticmethod
    def check_response_body_containing_array_of_uris_set_to(kwargs: list) -> str:
        return 'Response Body set to an array of created entities ids'

    @staticmethod
    def check_created_resources_set_to(kwargs: list) -> str:
        return 'Created resources set to ${entities}'

    @staticmethod
    def check_response_headers_containing_content_type_set_to(kwargs: list) -> str:
        if "content_type" in kwargs:
            content_type = kwargs['content_type']
            return f'Response Header: Content-Type set to {content_type}'
        else:
            raise Exception(f'ERROR, Expected status_code parameter but received: {kwargs}')

    @staticmethod
    def check_response_headers_link_not_empty(kwargs: list) -> str:
        return f'Response Header: Link is not Empty'

    @staticmethod
    def check_response_headers_containing_uri_set_to(kwargs: list) -> str:
        return 'Response Header: Location containing ${registration_id}'

    @staticmethod
    def check_response_headers_id_not_empty(kwargs: list) -> str:
        return 'Response Header: Location is not Empty'

    @staticmethod
    def check_response_body_containing_an_attribute_set_to(kwargs: list) -> str:
        if "attribute_name" in kwargs:
            attribute_name = kwargs['attribute_name']

            if "attribute_value" in kwargs:
                attribute_value = kwargs['attribute_value']
                result = (f"Response Body contains the attribute: '{attribute_name}', "
                          f"with the value: '{attribute_value}'")
            else:
                result = f"Response Body contains the attribute: '{attribute_name}'"

            return result
        else:
            raise Exception(f'ERROR, Expected status_code parameter but received: {kwargs}')

    @staticmethod
    def check_response_body_containing_entity_element(kwargs: list) -> str:
        return 'Response Body containing ${entity_representation}'

    @staticmethod
    def check_response_body_containing_list_containing_entity_elements(kwargs: list) -> str:
        return 'Response Body containing a list containing Entity elements, containing ${value} provided'

    @staticmethod
    def check_response_body_containing_list_containing_entity_elements_with_different_types(kwargs: list) -> str:
        return ('Response Body containing a list containing Entity elements, '
                'containing a list of entity types to be retrieved')

    @staticmethod
    def check_response_body_containing_entitytemporal_element(kwargs: list) -> str:
        return ('Response Body containing EntityTemporal element containing attribute instances '
                'in the time range specified by the NGSI-LD temporal query')

    @staticmethod
    def check_response_body_containing_list_containing_entitytemporal_elements(kwargs: list) -> str:
        if "timeRel" in kwargs and "timeAt" in kwargs:
            return (f"Response Body containing a list containing EntityTemporal elements containing entity type in the "
                    f"list of entity types provided and entity id matching id pattern provided and attribute instances "
                    f"'{kwargs['timeRel']}' '{kwargs['timeAt']}'")
        else:
            raise Exception(f'ERROR, timeRel and/or timeAt attributes were not provided, but received: {kwargs}')

    @staticmethod
    def check_response_body_containing_subscription_element(kwargs: list) -> str:
        return 'Response Body containing the representation of CSRS1'

    @staticmethod
    def check_response_body_containing_list_containing_subscription_elements(kwargs: list) -> str:
        if "number" in kwargs:
            number = kwargs['number']
            if isinstance(number, int):
                number = int(number)

                if number == 1:
                    return f"body set to list containing '{number}' subscription"
                elif number > 1:
                    return f"body set to list containing '{number}' subscriptions"
                else:
                    raise Exception(f'ERROR, number attribute must be an integer value gt 1')
            else:
                raise Exception(f'ERROR, number attribute must be an integer value')
        else:
            raise Exception(f'ERROR, number attribute was not provided, but received: {kwargs}')

    @staticmethod
    def check_response_body_containing_number_of_entities(kwargs: list) -> str:
        if "entity_type" in kwargs and 'number_entities' in kwargs:
            mumber_entityes = kwargs['number_entities']
            entity_type = kwargs['entity_type']
            return f"Response Body containing a list of entities ({mumber_entityes}) of type '{entity_type}'"
        else:
            raise Exception(f'ERROR, expected entity_type and number_entities attributes, but received: {kwargs}')

    @staticmethod
    def check_response_body_containing_context_source_registration_element(kwargs: list) -> str:
        if 'csr_description' in kwargs:
            csr = kwargs['csr_description']
            return f"Response body containing a '{csr}'"
        else:
            raise Exception(f"ERROR, expected csr_description attribute, but received: {kwargs}")


    @staticmethod
    def check_response_body_containing_entitytypelist_element(kwargs: list) -> str:
        if 'description' in kwargs:
            description = kwargs['description']
            return f"Response Body containing a '{description}'"
        else:
            raise Exception(f"ERROR, expected description attribute, but received: {kwargs}")

    @staticmethod
    def check_response_body_containing_entitytype_element(kwargs: list) -> str:
        if 'description' in kwargs:
            description = kwargs['description']
            return f"Response Body containing a '{description}'"
        else:
            raise Exception(f"ERROR, expected description attribute, but received: {kwargs}")

    @staticmethod
    def check_response_body_containing_entitytypeinfo_element(kwargs: list) -> str:
        return 'Response Body containing an Entity Type Info'

    @staticmethod
    def check_response_body_containing_attributelist_element(kwargs: list) -> str:
        return 'Response Body containing an Attribute List element'

    @staticmethod
    def check_response_body_containing_attribute_element(kwargs: list) -> str:
        return 'Response Body containing an array of Attributes'

    @staticmethod
    def check_response_body_containing_list_containing_context_source_registrations_elements(kwargs: list) -> str:
        return 'Response body set to list of all matching Context Source Registrations resolved against the default JSON-LD context'

    @staticmethod
    def check_response_body_type_when_using_session_request(kwargs: list) -> str:
        if 'type' in kwargs:
            type = kwargs['type']
            return f"Response Body containing the type '{type}'"
        else:
            raise Exception(f"ERROR, expected type attribute, but received: {kwargs}")

    @staticmethod
    def check_response_body_containing_problemdetails_element_containing_type_element_set_to(kwargs: list) -> str:
        if 'type' in kwargs:
            type = kwargs['type']
            return f"Response Body containing the type '{type}'"
        else:
            raise Exception(f"ERROR, expected type attribute, but received: {kwargs}")

    @staticmethod
    def check_response_body_title_when_using_session_request(kwargs: list) -> str:
        return "Response body containing 'title' element"

    @staticmethod
    def check_response_body_containing_problemdetails_element_containing_title_element(kwargs: list) -> str:
        return "Response body containing 'title' element"

    @staticmethod
    def check_rl_response_body_containing_problemdetails_element_containing_type_element_set_to(kwargs: list) -> str:
        if 'type' in kwargs:
            type = kwargs['type']
            return f"Response Body containing the type '{type}'"
        else:
            raise Exception(f"ERROR, expected type attribute, but received: {kwargs}")

    @staticmethod
    def check_rl_response_body_containing_problemdetails_element_containing_title_element(kwargs: list) -> str:
        return "Response body containing 'title' element"

    @staticmethod
    def check_json_value_in_response_body(kwargs: list) -> str:
        if 'key' in kwargs and 'value' in kwargs:
            key = kwargs['key']
            value = kwargs['value']
            return f"Response Body containing the key '{key}', with the value '{value}'"
        else:
            raise Exception(f"ERROR, expected key and value attributes, but received: {kwargs}")

    @staticmethod
    def check_pagination_prev_and_next_headers(kwargs: list) -> str:
        previous = None
        next = None
        if 'previous' in kwargs:
            previous = kwargs['previous']
            previous_text = f"with 'Prev' header equal to '{previous}'"

        if 'next' in kwargs:
            next = kwargs['next']
            next_text = f"with 'Next' header equal to '{next}'"

        if previous is None and next is None:
            raise Exception(f"ERROR, expected previous or next attributes, but received: {kwargs}")
        elif previous is not None and next is None:
            result = f"Response header {previous_text}"
        elif previous is None and next is not None:
            result = f"Response header {next_text}"
        else:
            result = f"Response heacer {previous_text} and {next_text}"

        return result

    @staticmethod
    def check_created_resource_set_to(kwargs: list) -> str:
            return "Created Entity set to ${entity}"

    def check_updated_resource_set_to(kwargs: list) -> str:
            return "Updated Entity set to ${entity}"

    def check_sut_not_containing_resource(kwargs: list) -> str:
        if "status_code" in kwargs:
            status_code = kwargs['status_code']
            return f'Response Status Code set to {status_code} ({HTTPStatus(status_code).phrase})'
        else:
            raise Exception(f'ERROR, Expected status_code parameter but received: {kwargs}')

    def get_checks(self, **kwargs) -> str:
        checking = None

        if "checks" in kwargs:
            checking = kwargs["checks"]
        else:
            raise Exception(f'ERROR,  the attribute checks is mandatory, but received: {kwargs}')

        if isinstance(checking, str):
            result = self.checks[checking](kwargs)
        elif isinstance(checking, list):
            result = [self.checks[x](kwargs) for x in checking]
            result = " and\n".join(result)
        else:
            raise Exception(f"ERROR, checks type not supported: {checking}")

        return result

    """
    then {
             the SUT sends a valid Response containing 
                      Response Status Code set to 201 (Created) and
                      Response Body set to an array of created entities ids
    
            and created resources set to ${entities}
    }
then {
         the SUT sends a valid Response containing 
                  Response Status Code set to ${status_code}
                  Response Body containing 
                         ${appended_attrs_list}
         and contains ${entity} with ${appended_attrs_list}
}
    """

    """
    * Check Response Body Content
    
    (is not a final check) Check Response Body Containing Batch Operation Result
                                                                                             
    * Check NotificationParams
            
    Check Updated Resources Set To
        
    Check SUT Not Containing Resources
    and the SUT not containing resources with id in ${existing_entities_ids}
    """


if __name__ == "__main__":
    data = Checks()

    print(data.get_checks(checks='Check Response Status Code',
                          status_code=201))
    print(data.get_checks(checks='Check Response Body Containing Array Of URIs set to'))
    print(data.get_checks(checks='Check Created Resources Set To'))
    print(data.get_checks(checks='Check Response Headers Containing Content-Type set to',
                          content_type='application/json'))
    print(data.get_checks(checks='Check Response Headers Link Not Empty'))
    print(data.get_checks(checks='Check Response Headers Containing URI set to'))
    print(data.get_checks(checks='Check Response Headers ID Not Empty'))
    print(data.get_checks(checks='Check Response Body Containing an Attribute set to',
                          attribute_name='status'))
    print(data.get_checks(checks='Check Response Body Containing an Attribute set to',
                          attribute_name='status',
                          attribute_value='active'))
    print(data.get_checks(checks='Check Response Body Containing Entity element'))
    print(data.get_checks(checks='Check Response Body Containing List Containing Entity Elements'))
    print(data.get_checks(checks='Check Response Body Containing List Containing Entity Elements With Different Types'))
    print(data.get_checks(checks='Check Response Body Containing EntityTemporal element'))
    print(data.get_checks(checks='Check Response Body Containing List Containing EntityTemporal elements',
                          timeRel='after',
                          timeAt='2020-07-01T12:05:00Z'))
    print(data.get_checks(checks='Check Response Body Containing Subscription element'))
    print(data.get_checks(checks='Check Response Body Containing List Containing Subscription elements',
                          number=2))
    print(data.get_checks(checks='Check Response Body Containing List Containing Subscription elements',
                          number=1))
    print(data.get_checks(checks='Check Response Body Containing Number Of Entities',
                          entity_type="Vehicle",
                          number_entities=3))
    print(data.get_checks(checks='Check Response Body Containing Context Source Registration element',
                          csr_description='Context Source Registration'))
    print(data.get_checks(checks='Check Response Body Containing EntityTypeList element',
                          description='Json object with list of entity types with context'))
    print(data.get_checks(checks='Check Response Body Containing EntityType element',
                          description='Json object with an entity type with context'))
    print(data.get_checks(checks='Check Response Body Containing EntityTypeInfo element'))
    print(data.get_checks(checks='Check Response Body Containing AttributeList element'))
    print(data.get_checks(checks='Check Response Body Containing Attribute element'))
    print(data.get_checks(checks='Check Response Body Containing List Containing Context Source Registrations elements'))
    print(data.get_checks(checks='Check Response Body Type When Using Session Request',
                          type='https://uri.etsi.org/ngsi-ld/errors/BadRequestData'))
    print(data.get_checks(checks='Check Response Body Containing ProblemDetails Element Containing Type Element set to',
                          type='https://uri.etsi.org/ngsi-ld/errors/BadRequestData'))
    print(data.get_checks(checks='Check Response Body Title When Using Session Request'))
    print(data.get_checks(checks='Check Response Body Containing ProblemDetails Element Containing Title Element'))
    print(data.get_checks(checks='Check RL Response Body Containing ProblemDetails Element Containing Type Element set to',
                          type='https://uri.etsi.org/ngsi-ld/errors/BadRequestData'))
    print(data.get_checks(checks='Check RL Response Body Containing ProblemDetails Element Containing Title Element'))
    print(data.get_checks(checks='Check JSON Value In Response Body',
                          key="['information']['entities'][0]['type']",
                          value="Building"))
    print(data.get_checks(checks='Check Pagination Prev And Next Headers',
                          previous='</ngsi-ld/v1/csourceSubscriptions?limit=1&page=1>;rel="prev";type="application/ld+json"',
                          next='</ngsi-ld/v1/csourceSubscriptions?limit=1&page=3>;rel="next";type="application/ld+json"'))
    print(data.get_checks(checks='Check Pagination Prev And Next Headers',
                          previous='',
                          next='</ngsi-ld/v1/csourceSubscriptions?limit=1&page=3>;rel="next";type="application/ld+json"'))
    print(data.get_checks(checks='Check Pagination Prev And Next Headers',
                          previous='</ngsi-ld/v1/csourceSubscriptions?limit=1&page=1>;rel="prev";type="application/ld+json"',
                          next=''))
    print(data.get_checks(checks='Check Pagination Prev And Next Headers',
                          previous='',
                          next=''))
    print(data.get_checks(checks='Check Created Resource Set To'))
    print(data.get_checks(checks='Check Updated Resource Set To'))
    print(data.get_checks(checks='Check SUT Not Containing Resource',
                          status_code=404))

    print()
    print(data.get_checks(checks=
                          ['Check Response Status Code',
                           'Check Response Body Containing Array Of URIs set to',
                           'Check Created Resources Set To']
                          , status_code=201))
    print()

    # Check exceptions
    try:
        print(data.get_checks(checks='Check Response Body Containing an Attribute set to'))
    except Exception as e:
        print(e)
