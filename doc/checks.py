from http import HTTPStatus


class Checks:
    def __init__(self):
        self.checks = {
            'Check Response Status Code': Checks.check_response_status_code,
            'Check Response Body Containing Array Of URIs set to': Checks.check_response_body_containing_array_of_uris_set_to,
            'Check Created Resources Set To': Checks.check_created_resources_set_to,
            'Check Response Headers Containing Content-Type set to': Checks.check_response_headers_containing_content_type_set_to,
            'Check Response Headers Link Not Empty':Checks.check_response_headers_link_not_empty,
            'Check Response Headers Containing URI set to': Checks.check_response_headers_containing_uri_set_to,
            'Check Response Headers ID Not Empty': Checks.check_response_headers_id_not_empty,
            'Check Response Body Containing an Attribute set to': Checks.check_response_body_containing_an_attribute_set_to
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
                result = f"Response Body contains the attribute: '{attribute_name}', with the value: '{attribute_value}'"
            else:
                result = f"Response Body contains the attribute: '{attribute_name}'"

            return result
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
    
    Check Response Body Containing Batch Operation Result
    
    Check Response Body Containing Entity element
    
    Check Response Body Containing List Containing Entity Elements
    
    Check Response Body Containing List Containing Entity Elements With Different Types
    
    Check Response Body Containing EntityTemporal element
    
    Check Response Body Containing List Containing EntityTemporal elements
    
    Check Response Body Containing Subscription element
    
    Check Response Body Containing List Containing Subscription elements
    
    Check Response Body Containing Number Of Entities
    
    Check Response Body Containing Context Source Registration element
    
    Check Response Body Containing EntityTypeList element
    
    Check Response Body Containing EntityType element
    
    Check Response Body Containing EntityTypeInfo element
    
    Check Response Body Containing AttributeList element
    
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

    print(data.get_checks(checks='Check Response Status Code', status_code=201))
    print(data.get_checks(checks='Check Response Body Containing Array Of URIs set to'))
    print(data.get_checks(checks='Check Created Resources Set To'))
    print(data.get_checks(checks='Check Response Headers Containing Content-Type set to', content_type='application/json'))
    print(data.get_checks(checks='Check Response Headers Link Not Empty'))
    print(data.get_checks(checks='Check Response Headers Containing URI set to'))
    print(data.get_checks(checks='Check Response Headers ID Not Empty'))
    print(data.get_checks(checks='Check Response Body Containing an Attribute set to', attribute_name='status'))
    print(data.get_checks(checks='Check Response Body Containing an Attribute set to', attribute_name='status', attribute_value='active'))

    print()
    print(data.get_checks(checks=
                          ['Check Response Status Code',
                           'Check Response Body Containing Array Of URIs set to',
                           'Check Created Resources Set To']
                          , status_code=201))

