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
                'positions': [1],
                'params': ['context']
            },
            'Retrieve Subscription': {
                'positions': [],
                'params': []
            },
            'Query Context Source Registrations With Return': {
                'positions': [],
                'params': []
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
                Requests.update_subscription
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

        # return request, params
        # Previous version
        # index = None
        # for k in keys:
        #     index = string.find(k)
        #     if index != -1:
        #         break
        #
        # pattern = f"^.*{k}.*\n"
        # lines_starting_with_request = re.findall(pattern, string, re.MULTILINE)
        # for line in lines_starting_with_request:
        #     data = line.strip().split("    ")
        #     if len(data) == 2:
        #         # We are in multiline definition
        #         params = self.find_attributes_next_line(string=string, position=index, request_name=k)
        #     else:
        #         # The definition of the request is in the same line
        #         params = self.find_attributes_in_the_same_line(request_name=k, params=data[1:])

        description = self.description[request](params)
        return description

    def find_attributes_in_the_same_line(self, request_name, params):
        param = dict()
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
            print(i)
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
        if 'context' in kwargs:
            result = f"Request Header['Link'] contain the context {kwargs['context']}"
            return result
        else:
            raise Exception(f"ERROR, expected context attribute, but received {kwargs}")

    @staticmethod
    def retrieve_subscription(kwargs) -> str:
        return "Request a subscription"

    def query_context_source_registrations_with_return(kwargs) -> str:
        return "Request a Context Source Registration with Return"

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

    def get_value(self, params, param_position, param_key):
        try:
            data = params[param_position]
        except IndexError:
            return ''

        if '=' in data:
            # The name of the attribute is passed to the function in the form attribute=value
            data = data.split('=')
            if data[0] != param_key:
                raise Exception(f"ERROR, uncontrolled param_key: {params} {param_key}")

            data = data[1]

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
