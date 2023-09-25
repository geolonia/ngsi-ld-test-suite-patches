import re


class Requests:
    def __init__(self, variables, apiutils_variables):
        self.op = {
            'Create Entity Selecting Content Type': {
                'positions': [1, 3],
                'params': ['filename', 'content_type']
            },
            'Create Subscription': {
                'positions': [2, 3],
                'params': ['filename', 'content_type']
            },
            'Create Or Update Temporal Representation Of Entity Selecting Content Type':  {
                'positions': [2, 3],
                'params': ['filename', 'content_type']
            },
            'Batch Create Entities': {
                'positions': [2],
                'params': ['content_type']
            },
            'Create Context Source Registration With Return': {
                'positions': [1],
                'params': ['filename']

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
                Requests.create_context_source_registration_with_return
            }
        self.variables = variables
        self.apiutils_variables = apiutils_variables

    def get_description(self, string):
        keys = self.op.keys()
        params = dict()

        index = None
        for k in keys:
            index = string.find(k)
            if index != -1:
                break

        pattern = f"^.*{k}.*\n"
        lines_starting_with_request = re.findall(pattern, string, re.MULTILINE)
        for line in lines_starting_with_request:
            data = line.strip().split("    ")
            if len(data) == 2:
                # We are in multiline definition
                params = self.find_attributes_next_line(string=string, position=index, request_name=k)
            else:
                # The definition of the request is in the same line
                params = self.find_attributes_in_the_same_line(request_name=k, params=data[1:])

        description = self.description[k](params)
        return description

    def find_attributes_in_the_same_line(self, request_name, params):
        param = dict()
        for i in range(0, len(self.op[request_name]['positions'])):
            param_position = self.op[request_name]['positions'][i]
            param_key = self.op[request_name]['params'][i]
            param_value = self.get_value(params=params, param_position=param_position)
            param[param_key] = param_value

        return param

    def find_attributes_next_line(self, string, position, request_name):
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
            param_value = self.get_value(params=params, param_position=param_position)
            param_key = self.op[request_name]['params'][i]
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

    def get_value(self, params, param_position):
        try:
            value = self.variables[params[param_position]]
            return value
        except KeyError:
            try:
                value = self.apiutils_variables[params[param_position]]
                return value
            except KeyError:
                return params[param_position]
