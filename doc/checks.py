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
                Checks.check_response_body_containing_attributelist_element
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

    def check_response_body_containing_entitytypeinfo_element(kwargs: list) -> str:
        return 'Response Body containing an Entity Type Info'

    def check_response_body_containing_attributelist_element(kwargs: list) -> str:
        return 'Response Body containing an Attribute List element'

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
                                              
    Check Response Body Containing Attribute element
    
    Check Response Body Containing List Containing Context Source Registrations elements
    
    Check Response Body Type When Using Session Request
    
    Check Response Body Containing ProblemDetails Element Containing Type Element set to
    
    Check Response Body Title When Using Session Request
    
    Check Response Body Containing ProblemDetails Element Containing Title Element
    
    Check RL Response Body Containing ProblemDetails Element Containing Type Element set to
    
    Check RL Response Body Containing ProblemDetails Element Containing Title Element
    
    Check JSON Value In Response Body
    
    Check NotificationParams
    
    Check Pagination Prev And Next Headers
    
    Check Resource Set To
    
    Check Created Resource Set To
    
    Check Updated Resource Set To
    
    Check Updated Resources Set To
    
    Check SUT Not Containing Resource
    
    Check SUT Not Containing Resources
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
