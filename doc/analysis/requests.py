import re


class Requests:
    def __init__(self, variables, apiutils_variables, config_file):
        self.op = {
            'Create Entity Selecting Content Type': {
                'positions': [0, 2],
                'params': ['filename', 'content_type']
            },
            'Create Subscription': {
                'positions': [1, 2],
                'params': ['filename', 'content_type']
            },
            'Create Or Update Temporal Representation Of Entity Selecting Content Type':  {
                'positions': [1, 2],
                'params': ['filename', 'content_type']
            },
            'Batch Create Entities': {
                'positions': [1],
                'params': ['content_type']
            },
            'Create Context Source Registration With Return': {
                'positions': [0],
                'params': ['filename']
            },
            'Query Entity': {
                'positions': [1, 1],
                'params': ['context', 'accept']
            },
            'Retrieve Subscription': {
                'positions': [],
                'params': ['id', 'accept', 'context', 'content_type']
            },
            'Query Context Source Registrations With Return': {
                'positions': [0, 1],
                'params': ["type", "accept"]
            },
            'Query Temporal Representation Of Entities With Return': {
                'positions': [],
                'params': []
            },
            'Partial Update Entity Attributes': {
                'positions': [2, 3, 4],
                'params': ['filename', "content", "context"]
            },
            'Update Subscription': {
                'positions': [1, 2, 3],
                'params': ['filename', 'content', 'context']

            },
            'Query Context Source Registration Subscriptions': {
                'positions': [],
                'params': ['context', 'limit', 'page', 'accept']
            },
            'Query Temporal Representation Of Entities': {
                'positions': [],
                'params': ['context', 'entity_types', 'entity_ids', 'entity_id_pattern',
                           'ngsild_query', 'csf', 'georel', 'geometry',
                           'coordinates', 'geoproperty', 'timerel', 'timeAt',
                           'attrs', 'limit', 'lastN', 'accept']

            },
            'Retrieve Attribute': {
                'positions': [0],
                'params': ['attribute_name']
            },
            'Retrieve Entity Type': {
                'positions': [0, 1],
                'params': ['type', 'context']
            },
            'Retrieve Entity by Id': {
                'positions': [],
                'params': ['id', 'accept', 'context']
            },
            'Query Entities': {
                'positions': [0, 1],
                'params': ['entity_ids', 'entity_types', 'accepts']
            },
            'Retrieve Temporal Representation Of Entity': {
                'positions': [],
                'params': ['temporal_entity_representation_id', 'attrs', 'options',
                           'context', 'timerel', 'timeAt',
                           'endTimeAt', 'lastN', 'accept']
            },
            'Delete Entity by Id Returning Response': {
                'positions': [0],
                'params': ['id']
            },
            'Append Entity Attributes': {
                'positions': [0, 1, 2],
                'params': ['id', 'fragment_filename', 'content_type']
            },
            'Update Entity Attributes': {
                'positions': [0, 1, 2],
                'params': ['id', 'fragment_filename', 'content_type']
            },
            'Delete Temporal Representation Of Entity With Returning Response': {
                'positions': [0],
                'params': ['id']
            },
            'Append Attribute To Temporal Entity': {
                'positions': [0, 1, 2],
                'params': ['id', 'fragment_filename', 'content_type']
            },
            'Delete Subscription': {
                'positions': [0],
                'params': ['id']
            },
            'Query Subscriptions': {
                'positions': [],
                'params': ['context', 'limit', 'offset', 'accept']
            },
            'Retrieve Context Source Registration Subscription': {
                'positions': [],
                'params': ['subscription_id', 'context', 'accept']
            },
            'Retrieve Context Source Registration': {
                'positions': [],
                'params': ['context_source_registration_id', 'context', 'accept']
            },
            'Delete Context Source Registration With Return': {
                'positions': [0],
                'params': ['id']
            },
            'Query Context Source Registrations': {
                'positions': [],
                'params': ['context', 'id', 'type', 'attrs',
                           'q', 'csf', 'georel', 'geometry',
                           'coordinates', 'geoproperty', 'timeproperty', 'timerel',
                           'timeAt', 'limit', 'page', 'accept']
            },
            'Update Context Source Registration With Return': {
                'positions': [0, 1, 2],
                'params': ['id', 'filename', 'content']
            },
            'Retrieve context source registration subscription': {
                'positions': [0],
                'params': ['id']
            },
            'Create Context Source Registration Subscription': {
                'positions': [0],
                'params': ['filename']
            },
            'Delete Context Source Registration Subscription': {
                'positions': [0],
                'params': ['id']
            },
            'Update Context Source Registration Subscription': {
                'positions': [0, 1],
                'params': ['subscription_id', 'subscription_update_fragment']
            },
            'Update Context Source Registration Subscription From File': {
                'positions': [0, 1],
                'params': ['subscription_id', 'subscription_update_fragment']
            }
        }

        self.description = {
            'Create Entity Selecting Content Type':
                Requests.create_entity_selecting_content_type,
            'Create Subscription':
                Requests.create_entity_selecting_content_type,
            'Create Or Update Temporal Representation Of Entity Selecting Content Type':
                Requests.create_entity_selecting_content_type,
            'Batch Create Entities':
                Requests.batch_create_entities,
            'Create Context Source Registration With Return':
                Requests.create_context_source_registration_with_return,
            'Query Entity':
                Requests.query_entity,
            'Retrieve Subscription':
                Requests.retrieve_subscription,
            'Query Context Source Registrations With Return':
                Requests.query_context_source_registrations_with_return,
            'Query Temporal Representation Of Entities With Return':
                Requests.query_temporal_representation_of_entities_with_return,
            'Partial Update Entity Attributes':
                Requests.partial_update_entity_attributes,
            'Update Subscription':
                Requests.update_subscription,
            'Query Context Source Registration Subscriptions':
                Requests.query_context_source_registration_subscriptions,
            'Query Temporal Representation Of Entities':
                Requests.query_temporal_representation_of_entities,
            'Retrieve Attribute':
                Requests.retrieve_attribute,
            'Retrieve Entity Type':
                Requests.retrieve_entity_type,
            'Retrieve Entity by Id':
                Requests.retrieve_entity_by_id,
            'Query Entities':
                Requests.query_entities,
            'Delete Entity by Id Returning Response':
                Requests.delete_entity_by_id_returning_response,
            'Append Entity Attributes':
                Requests.append_entity_attributes,
            'Update Entity Attributes':
                Requests.update_entity_attributes,
            'Retrieve Temporal Representation Of Entity':
                Requests.retrieve_temporal_representation_of_entity,
            'Delete Temporal Representation Of Entity With Returning Response':
                Requests.delete_temporal_representation_of_entity_with_returning_response,
            'Append Attribute To Temporal Entity':
                Requests.append_attribute_to_temporal_entity,
            'Delete Subscription':
                Requests.delete_subscription,
            'Query Subscriptions':
                Requests.query_subscriptions,
            'Retrieve Context Source Registration Subscription':
                Requests.retrieve_context_source_registration_subscription,
            'Retrieve Context Source Registration':
                Requests.retrieve_context_source_registration,
            'Delete Context Source Registration With Return':
                Requests.delete_context_source_registration_with_return,
            'Query Context Source Registrations':
                Requests.query_context_source_registrations,
            'Update Context Source Registration With Return':
                Requests.update_context_source_registration_with_return,
            'Retrieve context source registration subscription':
                Requests.retrieve_context_source_registration_subscription_2,
            'Create Context Source Registration Subscription':
                Requests.create_context_source_registration_subscription,
            'Delete Context Source Registration Subscription':
                Requests.delete_context_source_registration_subscription,
            'Update Context Source Registration Subscription':
                Requests.update_context_source_registration_subscription,
            'Update Context Source Registration Subscription From File':
                Requests.update_context_source_registration_subscription_from_file
        }

        self.variables = variables
        self.apiutils_variables = apiutils_variables
        self.config_file = config_file

    def get_description(self, string):
        keys = self.op.keys()
        params = dict()

        # New version
        lines_starting_response = re.findall(r'^\s*\$\{response\}.*', string, re.MULTILINE)

        # If there is more than one line, it means that the test case has several operations, all of them to
        # create the environment content to execute the last one, which is the correct one to test the Test Case
        if len(lines_starting_response) > 1:
            # The last one corresponds to the execution of the test, the rest corresponds to the initial condition of
            # test case...
            response_to_check = lines_starting_response[-1]
        else:
            response_to_check = lines_starting_response[0]

        index = string.find(response_to_check)
        aux = string[index:].split('\n')
        aux = [x for x in aux if x != '']

        params = list()
        request = str()

        # Get the list of params of the function, they are the keys
        if '    ...    ' in aux[1]:
            request = aux[0].split('    ')[2]
            # We are in the case that the attributes are in following lines
            for i in range(1, len(aux)):
                if '    ...    ' in aux[i]:
                    regex = '\s{4}\.{3}\s{4}(.*)'
                    param = re.match(pattern=regex, string=aux[i])
                    if aux:
                        params.append(param.groups()[0])
                else:
                    break

            #params = self.find_attributes_next_lines(string=string, position=index, request_name=request)
            params = self.find_attributes_in_the_same_line(request_name=request, params=params)
        else:
            # the attributes are in the same line
            regex = r"\s*\$\{response\}=\s{4}(.*)"
            matches = re.finditer(regex, response_to_check, re.MULTILINE)
            request = aux[0].split('    ')[2]

            # We have two options from here, or the parameters are defined in the same line or the parameters are defined in
            # following lines, next lines
            for match in matches:
                # Check that we have 1 group matched
                if len(match.groups()) == 1:
                    aux = match.group(1)

                    # Get the list of keys
                    params = aux.split('    ')[1:]
                else:
                    raise Exception(f"Error, unexpected format, received: '{response_to_check}'")

            params = self.find_attributes_in_the_same_line(request_name=request, params=params)

        description = self.description[request](params)
        return description

    def find_attributes_in_the_same_line(self, request_name, params):
        param = dict()
        if len(self.op[request_name]['positions']) == 0:
            # We do not know the position of the different parameters and the order in which they are received,
            # therefore in these cases all the parameters have identified the corresponding name
            param = {x.split('=')[0]: self.get_value_simple(x.split('=')[1]) for x in params}

        else:
            for i in range(0, len(self.op[request_name]['positions'])):
                param_position = self.op[request_name]['positions'][i]
                param_key = self.op[request_name]['params'][i]
                param_value = self.get_value(params=params, param_position=param_position, param_key=param_key)
                param[param_key] = param_value

        return param

    def find_attributes_next_lines(self, string, position, request_name):
        aux = string[position+len(request_name)+1:].split('\n')

        params = list()
        for a in range(0, len(aux)):
            param = aux[a]
            if param.startswith("    ..."):
                params.append(param.split('    ')[-1])
            else:
                break

        param = dict()
        for i in range(0, len(self.op[request_name]['positions'])):
            param_position = self.op[request_name]['positions'][i] - 1
            param_key = self.op[request_name]['params'][i]
            param_value = self.get_value(params=params, param_position=param_position, param_key=param_key)
            param[param_key] = param_value

        return param

    @staticmethod
    def create_entity_selecting_content_type(kwargs) -> str:
        if 'filename' in kwargs and 'content_type' in kwargs:
            result = (f"Request Header['Content-Type'] set to '{kwargs['content_type']}' and\n "
                      f"payload defined in file: '{kwargs['filename']}'")
            return result
        else:
            raise Exception(f"ERROR, expected filename and content_type attributes, but received {kwargs}")

    @staticmethod
    def batch_create_entities(kwargs) -> str:
        if 'content_type' in kwargs:
            result = (f"Request Header['Content-Type'] set to '{kwargs['content_type']}' and\n "
                      f"payload set to a list of entities to be created")
            return result
        else:
            raise Exception(f"ERROR, expected content_type attribute, but received {kwargs}")

    @staticmethod
    def create_context_source_registration_with_return(kwargs) -> str:
        if 'filename' in kwargs:
            result = (f"Request Header['Content-Type'] set to 'application/ld+json' and\n "
                      f"payload defined in file: '{kwargs['filename']}'")
            return result
        else:
            raise Exception(f"ERROR, expected filename attribute, but received {kwargs}")

    @staticmethod
    def query_entity(kwargs) -> str:
        result = ''
        if 'context' in kwargs and kwargs['context'] != '':
            result = f"Request Header['Link'] contain the context {kwargs['context']}"

        if 'accept' in kwargs:
            result = f"{result}\nHeader['Accept'] set to {kwargs['accept']}"

        if 'context' not in kwargs and 'accept' not in kwargs:
            raise Exception(f"ERROR, expected context attribute, but received {kwargs}")

        return result

    @staticmethod
    def retrieve_subscription(kwargs) -> str:
        # if 'accept' in kwargs:
        #     return f"Request a subscription\nHeader['Accept'] set to '{kwargs['accept']}'"
        # else:
        #     return "Request a subscription"
        expected_parameters = ['id', 'accept', 'context', 'content_type']

        result = [x for x in kwargs if x not in expected_parameters]
        response = "Subscription Retrieve with the following data:"
        for key, value in kwargs.items():
            match key:
                case 'id':
                    response = f"{response} and\n    Query Parameter: id set to '{value}'"
                case 'accept':
                    response = f"{response} and\n    Query Parameter: accept set to '{value}'"
                case 'context':
                    response = f"{response} and\n    Query Parameter: context set to '{value}'"
                case 'content_type':
                    response = f"{response} and\n    Query Parameter: content_type set to '{value}'"
                # If an exact match is not confirmed, this last case will be used if provided
                case _:
                    raise Exception(f"ERROR, unexpected attribute '{result}', the attributes expected are "
                                    f"'{expected_parameters}', but received: {kwargs}")

        return response

    def query_context_source_registrations_with_return(kwargs) -> str:
        if 'type' in kwargs and 'accept' in kwargs:
            result = "Request a Context Source Registration with Return"

            if kwargs['type'] != '':
                result = f"{result}\nEntity Type set to '{kwargs['type']}'"

            if kwargs['accept'] != '':
                result = f"{result}\nHeader['Accept'] set to '{kwargs['accept']}'"
        else:
            result = "Request a Context Source Registration with Return"

        return result

    def query_temporal_representation_of_entities_with_return(kwargs) -> str:
        return "Request a Temporal Representation of Entities with Return"

    def partial_update_entity_attributes(kwargs) -> str:
        if 'context' in kwargs and 'content' in kwargs and 'filename' in kwargs:
            context = kwargs['context']
            if context == '':
                return (f"Request Partial Update Entity Attributes and \n"
                        f"Header['Content-Type'] set to '{kwargs['content']}' and\n"
                        f"Payload defined in file '{kwargs['filename']}'")
            else:
                return (f"Request Partial Update Entity Attributes and \n"
                        f"Header['Link'] contain the context '{kwargs['context']}' and \n"
                        f"Header['Content-Type'] set to '{kwargs['content']}' and\n"
                        f"Payload defined in file '{kwargs['filename']}'")
        else:
            raise Exception(f"ERROR, expected context attribute, but received {kwargs}")

    def update_subscription(kwargs) -> str:
        if 'context' in kwargs and 'content' in kwargs and 'filename' in kwargs:
            context = kwargs['context']
            if context == '':
                return (f"Request Update Subscription and \n"
                        f"Header['Content-Type'] set to '{kwargs['content']}' and\n"
                        f"Payload defined in file '{kwargs['filename']}'")
            else:
                return (f"Request Update Subscription and \n"
                        f"Header['Link'] contain the context '{kwargs['context']}' and\n"
                        f"Header['Content-Type'] set to '{kwargs['content']}' and\n"
                        f"Payload defined in file '{kwargs['filename']}'")
        else:
            raise Exception(f"ERROR, expected context attribute, but received {kwargs}")

    @staticmethod
    def query_context_source_registration_subscriptions(kwargs) -> str:
        expected_parameters = ['context', 'limit', 'page', 'accept']

        result = [x for x in kwargs if x not in expected_parameters]
        response = "Query Context Source Registration Subscriptions"
        for key, value in kwargs.items():
            match key:
                case 'context':
                    response = f"{response} and\n    Query Parameter: context set to '{value}'"
                case 'limit':
                    response = f"{response} and\n    Query Parameter: limit set to '{value}'"
                case 'page':
                    response = f"{response} and\n    Query Parameter: page set to '{value}'"
                case 'accept':
                    response = f"{response} and\n    Query Parameter: accept set to '{value}'"
                # If an exact match is not confirmed, this last case will be used if provided
                case _:
                    raise Exception(f"ERROR, unexpected attribute '{result}', the attributes expected are "
                                    f"'{expected_parameters}', but received: {kwargs}")

        return response
        # if 'accept' in kwargs:
        #     return (f"Request Context Source Registration Subscriptions\n"
        #             f"Header['Accept'] set to '{kwargs['accept']}'")
        # else:
        #     raise Exception(f"ERROR, expected accept attribute, but received {kwargs}")

    @staticmethod
    def query_temporal_representation_of_entities(kwargs) -> str:
        # This function is a little bit special because we have a number of parameters not always defined and not always
        # in the same position, so we make a different analysis to extract the values
        expected_parameters = ['context', 'entity_types', 'entity_ids', 'entity_id_pattern',
                               'ngsild_query', 'csf', 'georel', 'geometry',
                               'coordinates', 'geoproperty', 'timerel', 'timeAt',
                               'attrs', 'limit', 'lastN', 'accept']

        result = [x for x in kwargs if x not in expected_parameters]
        response = ""
        for key, value in kwargs.items():
            match key:
                case 'context':
                    response = f"{response} and\n    Query Parameter: context set to '{value}'"
                case 'entity_types':
                    response = f"{response} and\n    Query Parameter: entity_types set to '{value}'"
                case 'entity_ids':
                    response = f"{response} and\n    Query Parameter: entity_ids set to '{value}'"
                case 'entity_id_pattern':
                    response = f"{response} and\n    Query Parameter: entity_id_pattern set to '{value}'"
                case 'ngsild_query':
                    response = f"{response} and\n    Query Parameter: ngsild_query set to '{value}'"
                case 'csf':
                    response = f"{response} and\n    Query Parameter: csf set to '{value}'"
                case 'georel':
                    response = f"{response} and\n    Query Parameter: georel set to '{value}'"
                case 'geometry':
                    response = f"{response} and\n    Query Parameter: geometry set to '{value}'"
                case 'coordinates':
                    response = f"{response} and\n    Query Parameter: coordinates set to '{value}'"
                case 'geoproperty':
                    response = f"{response} and\n    Query Parameter: geoproperty set to '{value}'"
                case 'timerel':
                    response = f"{response} and\n    Query Parameter: timerel set to '{value}'"
                case 'timeAt':
                    response = f"{response} and\n    Query Parameter: timeAt set to '{value}'"
                case 'attrs':
                    response = f"{response} and\n    Query Parameter: attrs set to '{value}'"
                case 'limit':
                    response = f"{response} and\n    Query Parameter: limit set to '{value}'"
                case 'lastN':
                    value = re.search(pattern=r'\d+', string=value).group()
                    response = f"{response} and\n    Query Parameter: lastN set to '{value}'"
                case 'accept':
                    response = f"{response} and\n    Query Parameter: accept set to '{value}'"

            # If an exact match is not confirmed, this last case will be used if provided
                case _:
                    raise Exception(f"ERROR, unexpected attribute '{result}', the attributes expected are "
                                    f"'{expected_parameters}', but received: {kwargs}")

        return response

    @staticmethod
    def retrieve_temporal_representation_of_entity(kwargs) -> str:
        expected_parameters = ['temporal_entity_representation_id', 'attrs', 'options',
                               'context', 'timerel', 'timeAt',
                               'endTimeAt', 'lastN', 'accept']
        result = [x for x in kwargs if x not in expected_parameters]
        response = "Retrieve Temporal Representation of Entity"
        for key, value in kwargs.items():
            match key:
                case 'temporal_entity_representation_id':
                    response = f"{response} and\n    Query Parameter: id set to '{value}'"
                case 'attrs':
                    response = f"{response} and\n    Query Parameter: attrs set to '{value}'"
                case 'options':
                    response = f"{response} and\n    Query Parameter: options set to '{value}'"
                case 'context':
                    response = f"{response} and\n    Query Parameter: context set to '{value}'"
                case 'timerel':
                    response = f"{response} and\n    Query Parameter: timerel set to '{value}'"
                case 'timeAt':
                    response = f"{response} and\n    Query Parameter: timeAt set to '{value}'"
                case 'endTimeAt':
                    response = f"{response} and\n    Query Parameter: endTimeAt set to '{value}'"
                case 'lastN':
                    value = re.search(pattern=r'\d+', string=value).group()
                    response = f"{response} and\n    Query Parameter: lastN set to '{value}'"
                case 'accept':
                    response = f"{response} and\n    Query Parameter: accept set to '{value}'"
                # If an exact match is not confirmed, this last case will be used if provided
                case _:
                    raise Exception(f"ERROR, unexpected attribute '{result}', the attributes expected are "
                                    f"'{expected_parameters}', but received: {kwargs}")

        return response

    @staticmethod
    def retrieve_attribute(kwargs) -> str:
        if 'attribute_name' in kwargs:
            return f"Retrieve Attribute with attributeName set to '{kwargs['attribute_name']}'"

    @staticmethod
    def retrieve_entity_type(kwargs) -> str:
        result = "Retrieve Entity Type"
        if 'type' in kwargs:
            result = f"{result}, with type set to '{kwargs['type']}'"

        if 'context' in kwargs and kwargs['context'] != '':
            result = f"{result}, with Header['Link'] containing '{kwargs['context']}'"

        if 'type' not in kwargs or 'context' not in kwargs:
            raise Exception(f"ERROR, expected type or context attributes, received '{kwargs}'")

        return result

    @staticmethod
    def query_entities(kwargs) -> str:
        result = "Request Query Entities"
        if 'entity_ids' in kwargs and kwargs['entity_ids'] != '':
            result = f"{result} with entity_ids set to '{kwargs['entity_ids']}'"

        if 'entity_types' in kwargs and kwargs['entity_types'] != '':
            result = f"{result} with entity_types set to '{kwargs['entity_types']}"

        if 'accept' in kwargs and kwargs['accept'] != '':
            result = f"{result} with Header['Accept'] set to '{kwargs['accept']}'"

        return result

    @staticmethod
    def retrieve_entity_by_id(kwargs) -> str:
        expected_parameters = ['id', 'accept', 'context']

        result = [x for x in kwargs if x not in expected_parameters]
        response = 'Request Retrieve Entity by Id'
        for key, value in kwargs.items():
            match key:
                case 'id':
                    response = f"{response} and\n    Query Parameter: id set to '{value}'"
                case 'accept':
                    response = f"{response} and\n    Query Parameter: accept set to '{value}'"
                case 'context':
                    response = f"{response} and\n    Query Parameter: context set to '{value}'"
                # If an exact match is not confirmed, this last case will be used if provided
                case _:
                    raise Exception(f"ERROR, unexpected attribute '{result}', the attributes expected are "
                                    f"'{expected_parameters}', but received: {kwargs}")

        return response

    @staticmethod
    def delete_entity_by_id_returning_response(kwargs) -> str:
        if 'id' in kwargs:
            return f"Delete Entity Request with id set to '{kwargs['id']}'"

    @staticmethod
    def delete_subscription(kwargs) -> str:
        if 'id' in kwargs:
            return f"Delete Subscription with id set to '{kwargs['id']}'"

    @staticmethod
    def query_subscriptions(kwargs) -> str:
        expected_parameters = ['context', 'limit', 'offset', 'accept']

        result = [x for x in kwargs if x not in expected_parameters]
        response = 'Query Subscription Request with data:'
        for key, value in kwargs.items():
            match key:
                case 'context':
                    response = f"{response} and\n    Query Parameter: context set to '{value}'"
                case 'limit':
                    response = f"{response} and\n    Query Parameter: limit set to '{value}'"
                case 'offset':
                    response = f"{response} and\n    Query Parameter: offset set to '{value}'"
                case 'accept':
                    response = f"{response} and\n    Query Parameter: accept set to '{value}'"
                # If an exact match is not confirmed, this last case will be used if provided
                case _:
                    raise Exception(f"ERROR, unexpected attribute '{result}', the attributes expected are "
                                    f"'{expected_parameters}', but received: {kwargs}")

        return response

    @staticmethod
    def retrieve_context_source_registration_subscription(kwargs) -> str:
        expected_parameters = ['subscription_id', 'context', 'accept']

        result = [x for x in kwargs if x not in expected_parameters]
        response = 'Retrieve Context Source Registration Subscription with data:'
        for key, value in kwargs.items():
            match key:
                case 'subscription_id':
                    response = f"{response} and\n    Query Parameter: subscription id set to '{value}'"
                case 'context':
                    response = f"{response} and\n    Query Parameter: context set to '{value}'"
                case 'accept':
                    response = f"{response} and\n    Query Parameter: accept set to '{value}'"
                # If an exact match is not confirmed, this last case will be used if provided
                case _:
                    raise Exception(f"ERROR, unexpected attribute '{result}', the attributes expected are "
                                    f"'{expected_parameters}', but received: {kwargs}")

        return response

    @staticmethod
    def delete_context_source_registration_with_return(kwargs) -> str:
        if 'id' in kwargs:
            return f"Delete Context Source Registration with id set to '{kwargs['id']}'"

    @staticmethod
    def update_context_source_registration_subscription(kwargs) -> str:
        if 'subscription_id' in kwargs and 'subscription_update_fragment' in kwargs:
            return (f"Update Context Source Registration Subscription "
                    f"with subscription id set to '{kwargs['subscription_id']}' and "
                    f"subscription update fragment set to '{kwargs['subscription_update_fragment']}'")
        else:
            raise Exception(f"ERROR, expected 'subscription_id' and 'subscription_update_fragment' but received: {kwargs}")

    @staticmethod
    def update_context_source_registration_subscription_from_file(kwargs) -> str:
        if 'subscription_id' in kwargs and 'subscription_update_fragment' in kwargs:
            return (f"Update Context Source Registration Subscription from file "
                    f"with subscription id set to '{kwargs['subscription_id']}' and "
                    f"subscription update fragment set to '{kwargs['subscription_update_fragment']}'")
        else:
            raise Exception(f"ERROR, expected 'subscription_id' and 'subscription_update_fragment' but received: {kwargs}")

    @staticmethod
    def retrieve_context_source_registration(kwargs) -> str:
        expected_parameters = ['context_source_registration_id', 'context', 'accept']

        result = [x for x in kwargs if x not in expected_parameters]
        response = 'Retrieve Context Source Registration with data:'
        for key, value in kwargs.items():
            match key:
                case 'context_source_registration_id':
                    response = f"{response} and\n    Query Parameter: context source registration id set to '{value}'"
                case 'context':
                    response = f"{response} and\n    Query Parameter: context set to '{value}'"
                case 'accept':
                    response = f"{response} and\n    Query Parameter: accept set to '{value}'"
                # If an exact match is not confirmed, this last case will be used if provided
                case _:
                    raise Exception(f"ERROR, unexpected attribute '{result}', the attributes expected are "
                                    f"'{expected_parameters}', but received: {kwargs}")

        return response

    @staticmethod
    def query_context_source_registrations(kwargs) -> str:
        expected_parameters = ['context', 'id', 'type', 'attrs',
                               'q', 'csf', 'georel', 'geometry',
                               'coordinates', 'geoproperty', 'timeproperty', 'timerel',
                               'timeAt', 'limit', 'page', 'accept']

        result = [x for x in kwargs if x not in expected_parameters]
        response = "Retrieve Temporal Representation of Entity"
        for key, value in kwargs.items():
            match key:
                case 'context':
                    response = f"{response} and\n    Query Parameter: context set to '{value}'"
                case 'id':
                    response = f"{response} and\n    Query Parameter: id set to '{value}'"
                case 'type':
                    response = f"{response} and\n    Query Parameter: type set to '{value}'"
                case 'attrs':
                    response = f"{response} and\n    Query Parameter: attrs set to '{value}'"
                case 'q':
                    response = f"{response} and\n    Query Parameter: q set to '{value}'"
                case 'csf':
                    response = f"{response} and\n    Query Parameter: csf set to '{value}'"
                case 'georel':
                    response = f"{response} and\n    Query Parameter: georel set to '{value}'"
                case 'geometry':
                    response = f"{response} and\n    Query Parameter: geometry set to '{value}'"
                case 'coordinates':
                    response = f"{response} and\n    Query Parameter: coordinates set to '{value}'"
                case 'geoproperty':
                    response = f"{response} and\n    Query Parameter: geoproperty set to '{value}'"
                case 'timeproperty':
                    response = f"{response} and\n    Query Parameter: timeproperty set to '{value}'"
                case 'timerel':
                    response = f"{response} and\n    Query Parameter: timerel set to '{value}'"
                case 'timeAt':
                    response = f"{response} and\n    Query Parameter: timeAt set to '{value}'"
                case 'limit':
                    response = f"{response} and\n    Query Parameter: limit set to '{value}'"
                case 'page':
                    response = f"{response} and\n    Query Parameter: page set to '{value}'"
                case 'accept':
                    response = f"{response} and\n    Query Parameter: accept set to '{value}'"
                # If an exact match is not confirmed, this last case will be used if provided
                case _:
                    raise Exception(f"ERROR, unexpected attribute '{result}', the attributes expected are "
                                    f"'{expected_parameters}', but received: {kwargs}")

        return response

    @staticmethod
    def update_context_source_registration_with_return(kwargs) -> str:
        if 'id' in kwargs and 'filename' in kwargs and 'content' in kwargs:
            return (f"Update Context Source Registration with id set to '{kwargs['id']}' "
                    f"and registration update fragment set to '{kwargs['filename']}' "
                    f"and content-type set to '{kwargs['content']}'")

    @staticmethod
    def delete_temporal_representation_of_entity_with_returning_response(kwargs) -> str:
        if 'id' in kwargs:
            return f"Delete Temporal Representation Of Entity With Returning Response with id set to '{kwargs['id']}'"

    @staticmethod
    def retrieve_context_source_registration_subscription_2(kwargs) -> str:
        if 'id' in kwargs:
            return f"Retrieve Context Source Registration Subscription with id set to '{kwargs['id']}'"
        else:
            raise Exception(f"ERROR, expected 'id' but received: '{kwargs}'")

    @staticmethod
    def delete_context_source_registration_subscription(kwargs) -> str:
        if 'id' in kwargs:
            return f"Delete Context Source Registration Subscription with id set to '{kwargs['id']}'"
        else:
            raise Exception(f"ERROR, expected 'id' but received: '{kwargs}'")

    @staticmethod
    def create_context_source_registration_subscription(kwargs) -> str:
        if 'filename' in kwargs:
            return f"Create Context Source Registration Subscription with filename set to '{kwargs['filename']}'"
        else:
            raise Exception(f"ERROR, expected 'filename' but received: '{kwargs}'")

    @staticmethod
    def append_attribute_to_temporal_entity(kwargs) -> str:
        expected_parameters = ['id', 'fragment_filename', 'content_type']

        result = [x for x in kwargs if x not in expected_parameters]
        response = 'Append Attribute to Temporal Entity'
        for key, value in kwargs.items():
            match key:
                case 'id':
                    response = f"{response} and\n    Query Parameter: id set to '{value}'"
                case 'fragment_filename':
                    response = f"{response} and\n    Query Parameter: fragment_filename set to '{value}'"
                case 'content_type':
                    response = f"{response} and\n    Query Parameter: content_type set to '{value}'"
                # If an exact match is not confirmed, this last case will be used if provided
                case _:
                    raise Exception(f"ERROR, unexpected attribute '{result}', the attributes expected are "
                                    f"'{expected_parameters}', but received: {kwargs}")

        return response

    @staticmethod
    def append_entity_attributes(kwargs) -> str:
        expected_parameters = ['id', 'fragment_filename', 'content_type']

        result = [x for x in kwargs if x not in expected_parameters]
        response = 'Append Entity Attributes'
        for key, value in kwargs.items():
            match key:
                case 'id':
                    response = f"{response} and\n    Query Parameter: id set to '{value}'"
                case 'fragment_filename':
                    response = f"{response} and\n    Query Parameter: fragment_filename set to '{value}'"
                case 'content_type':
                    response = f"{response} and\n    Query Parameter: content_type set to '{value}'"
                # If an exact match is not confirmed, this last case will be used if provided
                case _:
                    raise Exception(f"ERROR, unexpected attribute '{result}', the attributes expected are "
                                    f"'{expected_parameters}', but received: {kwargs}")

        return response

    @staticmethod
    def update_entity_attributes(kwargs) -> str:
        expected_parameters = ['id', 'fragment_filename', 'content_type']

        result = [x for x in kwargs if x not in expected_parameters]
        response = 'Update Entity Attributes'
        for key, value in kwargs.items():
            match key:
                case 'id':
                    response = f"{response} and\n    Query Parameter: id set to '{value}'"
                case 'fragment_filename':
                    response = f"{response} and\n    Query Parameter: fragment_filename set to '{value}'"
                case 'content_type':
                    response = f"{response} and\n    Query Parameter: content_type set to '{value}'"
                # If an exact match is not confirmed, this last case will be used if provided
                case _:
                    raise Exception(f"ERROR, unexpected attribute '{result}', the attributes expected are "
                                    f"'{expected_parameters}', but received: {kwargs}")

        return response

    def get_value(self, params, param_position, param_key):
        data = [x for x in params if f'{param_key}=' in x]

        if len(data) == 1:
            # The name of the attribute is passed to the function in the form attribute=value
            data = data[0]
            data = data.split('=')
            if data[0] != param_key:
                return ''

            data = data[1]
        elif len(data) == 0:
            # There is no attribute=something therefore we have to apply the position
            try:
                data = params[param_position]

                # Workaround
                if 'accept' in data and param_key != 'accept':
                    data = ''
            except IndexError:
                return ''

        return self.get_value_simple(data=data)

    def get_value_simple(self, data):
        try:
            value = self.variables[data]
            return value
        except KeyError:
            try:
                value = self.apiutils_variables[data]
                return value
            except KeyError:
                try:
                    value = self.config_file.get_variable(variable=data)
                    return value
                except KeyError:
                    return data
