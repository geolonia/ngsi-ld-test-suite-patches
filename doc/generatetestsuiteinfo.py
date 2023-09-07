from pprint import pprint
from os import getcwd
from robot.api import TestSuiteBuilder
from parserobotfile import ParseRobotFile
from parseapiutilsfile import ParseApiUtilsFile
import re


class GenerateRobotData:
    def __init__(self, robot_file: str, execdir: str):
        self.robot = ParseRobotFile(filename=robot_file, execdir=execdir)
        self.apiutil = ParseApiUtilsFile(filename=self.robot.resource_file)
        self.suite = TestSuiteBuilder().build(robot_file)
        self.test_cases = list()
        self.test_suite = dict()
        self.identifier = {
            'ContextInformation': 'CI',
            'CommonBehaviours': 'CB',
            'Consumption': 'Cons',
            'Entity/RetrieveEntity': 'E'
        }
        self.references = {
            'v1.3.1': 'ETSI GS CIM 009 V1.3.1 [], clause '
        }
        self.initial_conditions = {
            'Setup Initial Entity':
                'with {\n    the SUT containing an initial Entity ${entity} with an id set to ${entityId}\n}',
            'Initial State':
                'with {\n    the SUT in the "initial state"\n}'
        }
        self.headers = {
            '${CONTENT_TYPE_LD_JSON}': 'Content-Type'
        }
        self.ids = {
            '${ENTITIES_ENDPOINT_PATH}': '${entityId}'
        }
        self.base_TP_id = str()

    def get_info(self):
        return self.test_suite

    def parse_robot(self):
        self.start_suite()
        _ = [self.visit_test(test=x) for x in self.suite.tests]

        _ = [self.get_step_data(test=x.name) for x in self.suite.tests]
        self.test_suite['test_cases'] = self.test_cases

        print()

    def get_params(self, string: str):
        params = list()
        request = str()
        index_start = string.find('${response}')
        aux = string[index_start:].split('\n')

        # Get the list of params of the function, they are the keys
        if '    ...    ' in aux[1]:
            request = aux[0].split('    ')[1]
            # We are in the case that the attributes are in following lines
            for i in range(1, len(aux)):
                if '    ...    ' in aux[i]:
                    regex = '\s{4}\.{3}\s{4}(.*)'
                    param = re.match(pattern=regex, string=aux[i])
                    if aux:
                        params.append(param.groups()[0])
                else:
                    break
        else:
            # the attributes are in the same line
            regex = r"\s*\$\{response\}=\s{4}(.*)\n"
            matches = re.finditer(regex, string, re.MULTILINE)
            request = aux[0].split('    ')[1]

            # We have two options from here, or the parameters are defined in the same line or the parameters are defined in
            # following lines, next lines
            for match in matches:
                # Check that we have 1 group matched
                if len(match.groups()) == 1:
                    aux = match.group(1)

                    # Get the list of keys
                    params = aux.split('    ')[1:]
                else:
                    print("Error, unexpected format")

        return request, params

    def get_step_data(self, test: str):
        string = self.robot.get_substring(initial_string=test, final_string=self.suite.name, include=False)

        request, params = self.get_params(string=string)

        self.check_header_parameters(params=params, test=test)

        verb, url = self.apiutil.get_response(keyword=request)

        index = None
        for i, item in enumerate(self.test_cases):
            if 'name' in item and item['name'] == test:
                index = i
                break

        self.test_cases[index]['http_verb'] = verb
        self.test_cases[index]['endpoint'] = self.get_header_value(key=url)

        expected_status_code = self.robot.get_expected_status_code(keyword='Check Response Status Code')
        self.test_cases[index]['expected_status_code'] = expected_status_code


    def check_header_parameters(self, params: list, test: str):
        value = str()

        # 1st case: value of the parameters are sent as it is
        header_key = [x for x in params if x in self.headers.keys()]
        if len(header_key) != 0:
            key = header_key[0]
            value = self.get_header_value(key=key)
        else:
            # 2nd case, maybe the params are defined in the way <param>=<value>
            for k in self.headers:
                aux = [x for x in params if k in x]

            if len(aux) != 0:
                key = aux[0].split('=')[1]
                value = self.get_header_value(key=key)
            else:
                key = None
                value = None

        if key is not None and value is not None:
            # Iterate over the list and find the index
            index = None
            for i, item in enumerate(self.test_cases):
                if 'name' in item and item['name'] == test:
                    index = i
                    break

            self.test_cases[index]['params'] = params
            self.test_cases[index][self.headers[key]] = value

    def get_header_value(self, key: str):
        value = str()
        # We can have a simple variable or a compound of two variables
        count = key.count('$')
        if count == 1:
            # Get the value of the Header key
            try:
                value = self.apiutil.variables[key]
            except KeyError:
                # It is not defined in ApiUtils, maybe in Robot File
                try:
                    value = self.robot.variables[key]
                except KeyError:
                    # ERROR, the header key is not defined
                    print(f'ERROR, the header key {key} is undefined')
        elif count == 2:
            keys = key.split("$")
            key = f'${keys[1]}'
            second_key = f'${keys[2]}'

            try:
                second_key = self.ids[key]
            except KeyError:
                print(f"ERROR: Need to manage the {second_key} in GenerateRobotData::self.ids")
            # Get the value of the Header key
            try:
                value = self.apiutil.variables[key]
                value = f'{value}{second_key}'
            except KeyError:
                # It is not defined in ApiUtils, maybe in Robot File
                try:
                    value = self.robot.variables[key]
                    value = f'{value}{second_key}'
                except KeyError:
                    # ERROR, the header key is not defined
                    print(f'ERROR, the header key {key} is undefined')



        return value

    def start_suite(self):
        """Modify suite's tests to contain only every Xth."""
        version = 'v1.3.1'
        tp_id = self.generate_name()
        reference, pics = self.generate_reference(version=version)

        self.test_suite = {
            'tp_id': tp_id,
            'test_objective': self.suite.doc,
            'reference': reference,
            'config_id': '',
            'parent_release': version,
            'pics_selection': pics,
            'keywords': self.suite.keywords,
            'teardown': self.suite.teardown,
            'initial_condition': self.suite.setup,
            'test_cases': list()
        }

    def visit_test(self, test):
        test_case = {
            'name': test.name,
            'permutation_tp_id': f'{self.base_TP_id}/{test.name.split(" ")[0]}',
            'doc': test.doc,
            'tags': list(test.tags),
            'setup': test.setup.name,
            'teardown': test.teardown.name,
            'template': test.template
        }

        try:
            self.test_suite['initial_condition'] = self.initial_conditions[test.setup.name]
        except KeyError:
            self.test_suite['initial_condition'] = self.initial_conditions['Initial State']

        self.test_cases.append(test_case)

    def generate_name(self):
        current_path = getcwd()
        tp_id = str(self.suite.source.parent)[len(current_path):]

        if tp_id[0:4] == '/../':
            tp_id = tp_id[4:]

        for key, value in self.identifier.items():
            tp_id = tp_id.replace(key, value)

        self.base_TP_id = tp_id

        name = self.suite.name.replace(" ", "_")
        tp_id = f'{self.base_TP_id}/{name}'

        return tp_id

    def generate_reference(self, version):
        # Get the list of tags in the different tests
        aux = [x.tags for x in self.suite.tests]
        aux = [element for sublist in aux for element in sublist if element[0].isdigit()]
        check_tags = all(item == aux[0] for item in aux)

        if check_tags is False or len(aux) == 0:
            print(f'ERROR: the Test Suite {self.suite.name} has different clauses or no clauses (Tags): {aux}\n'
                  f'Unable to select the corresponding Reference of this Test Suite')
            reference = ''
            pics = ''
        else:
            # All the clauses are the same, so we select the first one
            reference = f'{self.references[version]}{aux[0].replace("_", ".")}'
            pics = f'PICS_{aux[0]}'

        return reference, pics


data = GenerateRobotData(robot_file='../TP/NGSI-LD/CommonBehaviours/043.robot',
                         execdir='/home/fla/Documents/workspace/bdd/ngsi-ld-test-suite')
data.parse_robot()
info = data.get_info()
pprint(info)

data = GenerateRobotData(robot_file='../TP/NGSI-LD/ContextInformation/Consumption/Entity/RetrieveEntity/018_06.robot',
                         execdir='/home/fla/Documents/workspace/bdd/ngsi-ld-test-suite')
data.parse_robot()
info = data.get_info()
pprint(info)
