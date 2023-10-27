from os.path import dirname
from robot.api import TestSuiteBuilder
from analysis.parserobotfile import ParseRobotFile
from analysis.parseapiutilsfile import ParseApiUtilsFile
from analysis.parsevariablesfile import ParseVariablesFile
import re


class GenerateRobotData:
    def __init__(self, robot_file: str, execdir: str):
        self.robot_file = robot_file
        self.execdir = execdir
        self.suite = TestSuiteBuilder().build(robot_file)

        self.config_variables = ParseVariablesFile()
        self.robot = ParseRobotFile(filename=robot_file, execdir=execdir, config_file=self.config_variables)
        # TODO: the robot file can provide several ApiUtils not only one
        self.apiutil = ParseApiUtilsFile(filename=self.robot.resource_file)
        self.robot.set_apiutils(self.apiutil)

        self.test_cases = list()
        self.test_suite = dict()
        self.tags_template = list()
        self.documentation_template = str()
        self.arguments = list()
        self.args = list()
        self.identifier = {
            'ContextInformation': 'CI',
            'CommonBehaviours': 'CB',
            'Consumption': 'Cons',
            'Provision': 'Prov',
            'ContextSource': 'CS',
            'Discovery/RetrieveAvailableAttributeInformation': 'DISC',
            'Discovery/RetrieveAvailableEntityTypeInformation': 'DISC',
            'Entity/RetrieveEntity': 'E',
            'Entities/CreateEntity': 'E',
            'Entity/QueryEntities': 'E',
            'BatchEntities/CreateBatchOfEntities': 'BE',
            'BatchEntities/UpsertBatchOfEntities': 'BE',
            'BatchEntities/UpdateBatchOfEntities': 'BE',
            'TemporalEntity/QueryTemporalEvolutionOfEntities': 'TE',
            'TemporalEntity/DeleteTemporalRepresentationOfEntity': 'TE',
            'TemporalEntity/UpdateTemporalRepresentationOfEntity': 'TE',
            'TemporalEntityAttributes/DeleteAttributeInstance': 'TEA',
            'TemporalEntityAttributes/DeleteAttribute': 'TEA',
            'TemporalEntityAttributes/ModifyAttributeInstance': 'TEA',
            'Subscription/CreateSubscription': 'SUB',
            'Subscription/DeleteSubscription': 'SUB',
            'Subscription/QuerySubscriptions': 'SUB',
            'Subscription/RetrieveSubscription': 'SUB',
            'Subscription/UpdateSubscription': 'SUB',
            'Subscription/Notification': 'SUB',
            'Registration/CreateContextSourceRegistration': 'REG',
            'Registration/CreateCSRegistration': 'REG',
            'Registration/QueryCSRegistrations': 'REG',
            'Registration/RetrieveCSRegistration': 'REG',
            'Registration/UpdateCSRegistration': 'REG',
            'Registration/DeleteCSRegistration': 'REG',
            'RegistrationSubscription/CreateCSRegistrationSubscription': 'REGSUB',
            'RegistrationSubscription/UpdateCSRegistrationSubscription': 'REGSUB',
            'RegistrationSubscription/RetrieveCSRegistrationSubscription': 'REGSUB',
            'RegistrationSubscription/QueryCSRegistrationSubscriptions': 'REGSUB',
            'RegistrationSubscription/DeleteCSRegistrationSubscription': 'REGSUB',
            'RegistrationSUBBehaviour': 'REGSUB'
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
        self.test_suite['robotpath'] = (self.robot_file.replace(f'{self.execdir}/TP/NGSI-LD/', '')
                                        .replace(f'/{self.robot.test_suite}.robot', ''))
        self.test_suite['robotfile'] = self.robot.test_suite
        return self.test_suite

    def parse_robot(self):
        self.start_suite()
        _ = [self.visit_test(test=x) for x in self.suite.tests]

        _ = [self.get_step_data(test=x.name) for x in self.suite.tests]
        self.test_suite['test_cases'] = self.test_cases

        # Generate the permutation keys to provide the keys in test_cases list that are different
        self.test_suite['permutations'] = self.get_permutation_keys(data=self.test_suite['test_cases'])

    def get_permutation_keys(self, data):
        all_keys = set().union(*data)
        excluded_keys = ['doc', 'permutation_tp_id', 'setup', 'teardown', 'name', 'tags']
        all_keys = [x for x in all_keys if x not in excluded_keys]
        keys_with_different_values = [
            key for key in all_keys if any(d.get(key) != data[0].get(key) for d in data[1:])
        ]

        return keys_with_different_values

    def get_data_template(self, string: str) -> str:
        if self.robot.test_template_name != '':
            result = self.robot.string_test_template
        else:
            result = string

        return result

    def get_params(self, test_case: str):
        test_case = self.get_data_template(string=test_case)
        lines_starting_response = re.findall(r'^\s*\$\{response\}.*|^\s*\$\{notification\}.*', test_case, re.MULTILINE)

        # If there is more than one line, it means that the test case has several operations, all of them to
        # create the environment content to execute the last one, which is the correct one to test the Test Case
        if (len(lines_starting_response) > 1 and
                any(map(lambda item: 'notification' in item, lines_starting_response)) == False):
            # The last one corresponds to the execution of the test, the rest corresponds to the initial condition of
            # test case...
            response_to_check = lines_starting_response[-1]
        else:
            response_to_check = lines_starting_response[0]

        index = test_case.find(response_to_check)
        aux = test_case[index:].split('\n')
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

        return request, params

    def get_step_data(self, test: str):
        if self.robot.string_test_template == '':
            string = self.robot.test_cases[test]
        else:
            string = self.robot.string_test_template

        request, params = self.get_params(test_case=string)
        verb, url = self.apiutil.get_response(keyword=request)

        index = None
        for i, item in enumerate(self.test_cases):
            if 'name' in item and item['name'] == test:
                index = i
                break

        self.test_cases[index]['http_verb'] = verb
        self.test_cases[index]['endpoint'] = self.get_values_url(keys=url, request=request, params=params)
        self.test_cases[index]['when'] = self.robot.generate_when_content(http_verb=self.test_cases[index]['http_verb'],
                                                                          endpoint=self.test_cases[index]['endpoint'],
                                                                          when=self.test_cases[index]['when'])

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

            # self.test_cases[index]['params'] = params
            self.test_cases[index][self.headers[key]] = value

    def get_values_url(self, keys: list, request: str, params: list) -> str:
        data = [self.get_value_url(key=x, request=request, params=params) for x in keys]
        data = '/'.join(data).replace('//', '/').replace('?/','?')
        return data

    def get_value_url(self, key: str, request: str, params: list) -> str:
        key_to_search = f'${key}'
        try:
            value = self.apiutil.variables[key_to_search]
        except KeyError:
            # It is not defined in ApiUtils, maybe in Robot File?
            try:
                value = self.robot.variables[key_to_search]
            except KeyError:
                # Maybe the url is defined in the proper resource file through an operation
                try:
                    value = self.check_resource_for_url(string=key_to_search, request=request, params=params)
                except KeyError:
                    # The variable is not defined, so it is keep as it is in the url
                    value = key

        return value

    def check_resource_for_url(self, string: str, request: str, params: list) -> str:
        index1 = self.apiutil.file_contents.find(string)

        if index1 != -1:
            index2 = self.apiutil.file_contents[index1:].find("\n")
            line = self.apiutil.file_contents[index1:index1+index2]

            if string in line:
                if 'Get From Dictionary' in line:
                    # We have to obtain the information of the endpoint from the dictionary
                    aux = line.split("Get From Dictionary")[1].strip().split("    ")
                    key = aux[0]
                    value = aux[1]
                    url_dict = self.apiutil.variables[key]

                    if request == 'Batch Request Entities From File':
                        url = url_dict[params[0]]
                    else:
                        raise KeyError

                    return url
                else:
                    raise KeyError
            else:
                raise KeyError
        else:
            raise KeyError

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
                    raise Exception(f"ERROR, the header key '{key}' is undefined")
        elif count == 2:
            keys = key.split("$")
            key = f'${keys[1]}'
            second_key = f'${keys[2]}'

            try:
                second_key = self.ids[key]
            except KeyError:
                raise Exception(f"ERROR: Need to manage the '{second_key}' in GenerateRobotData::self.ids")
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
                    raise Exception(f"ERROR, the header key '{key}' is undefined")

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
            'keywords': [str(x) for x in self.suite.keywords],
            'teardown': str(self.suite.teardown),
            'initial_condition': self.suite.setup,
            'test_cases': list()
        }

    def visit_test(self, test):
        # Get Tags associated to the test
        if len(test.tags) == 0 and self.tags_template is not None:
            tags = self.tags_template
        else:
            tags = list(test.tags)

        # Get the Documentation associated to the test
        if len(test.doc) == 0 and self.documentation_template is not None:
            documentation = self.documentation_template
        else:
            documentation = test.doc

        # Get the Content-Type and Body associated to the Test
        if len(self.args) != 0:
            # We are talking about Test Cases with Test Template, so we need to check the keyword content with the
            # definition of the template

            # Generate Checks for Test Data
            then = self.robot.get_checks(test_name=test.template, apiutils=self.apiutil, name=test.name)

            # Generate Request for Test Data
            when = self.robot.get_request(test_name=test.template, name=test.name)
        else:
            # We are talking about a Test Cases without Test Template
            # Generate Checks for Test Data
            then = self.robot.get_checks(test_name=test.name, apiutils=self.apiutil, name=test.name)

            # Generate Request for Test Data
            when = self.robot.get_request(test_name=test.name, name=test.name)

        test_case = {
            'name': test.name,
            'permutation_tp_id': f'{self.base_TP_id}/{test.name.split(" ")[0]}',
            'doc': documentation,
            'tags': tags,
            'setup': test.setup.name,
            'teardown': test.teardown.name,
            'template': test.template,
            'then': then,
            'when': when
        }

        try:
            self.test_suite['initial_condition'] = self.initial_conditions[test.setup.name]
        except KeyError:
            self.test_suite['initial_condition'] = self.initial_conditions['Initial State']

        self.test_cases.append(test_case)

    def get_body(self, string: str) -> str:
        aux = string.split(' ')[1:]

        if len(aux) >= 2:
            aux = [self.get_body(x) for x in aux]
            aux = ' '.join(aux)
        elif len(aux) == 1:
            aux = re.sub(r'([a-z])([A-Z])', r'\1 \2', aux[0])
        else:
            aux = re.sub(r'([a-z])([A-Z])', r'\1 \2', string)

        return aux

    def generate_name(self):
        base_dir = dirname(dirname(dirname(__file__)))
        tp_id = str(self.suite.source.parent).replace(f'{base_dir}/', "")

        for key, value in self.identifier.items():
            tp_id = tp_id.replace(key, value)

        self.base_TP_id = tp_id

        name = self.suite.name.replace(" ", "_")
        tp_id = f'{self.base_TP_id}/{name}'

        return tp_id

    def generate_reference(self, version):
        # Get the list of tags in the different tests
        tags = [x.tags for x in self.suite.tests]
        tags = [element for sublist in tags for element in sublist if element[0].isdigit()]

        if len(tags) == 0:
            # We have different tests cases that call a test template, maybe the Tags are defined in the template
            reference, pics = self.generate_reference_template(version=version)
        else:
            # We have normal tests cases
            reference, pics = self.generate_reference_testcases(tags=tags, version=version)

        return reference, pics

    def generate_reference_template(self, version):
        # Get the list of arguments, we select the first one because the 2nd keyword corresponds
        # to the teardown operation
        args = [list(x.keywords)[0] for x in self.suite.tests]
        args = [{str(x.parent): list(x.args)} for x in args]
        self.args = dict()
        _ = [self.args.update(x) for x in args]


        template_name = list(set([list(x.keywords)[0].name for x in self.suite.tests]))[0]

        # Due to the information of the tags are contained in the Keyword description of the template, we need to
        # analyse the Keyword.
        string = self.robot.get_substring(initial_string='** Keywords ***', final_string='', include=False)
        reference, pics = self.get_info_from_template(name=template_name, string=string, version=version)

        return reference, pics

    def get_info_from_template(self, name: str, string: str, version: str):
        # TODO: Check that the name of the template is in the string receive
        # Get the Tags line and the tag value
        tags = self.get_substring(string=string, key='[Tags]')
        self.tags_template = tags[1:]

        try:
            tag = list(set([element for sublist in tags for element in tags if element[0].isdigit()]))[0]
        except IndexError:
            raise Exception("ERROR, Probably [Tags] does not include reference to the section in the spec.")

        reference = f'{self.references[version]}{tag.replace("_", ".")}'
        pics = f'PICS_{tag}'

        # Get the arguments
        self.arguments = self.get_substring(string=string, key='[Arguments]')
        self.arguments = self.arguments[1:]

        # Get the documentation
        self.documentation_template = self.get_substring(string=string, key='[Documentation]')
        self.documentation_template = self.documentation_template[1:][0]

        return reference, pics

    def get_substring(self, string: str, key: str):
        pos1 = string.find(key) - 1
        pos2 = string[pos1:].find('\n')
        result = string[pos1:pos1+pos2].split('    ')

        return result

    def generate_reference_testcases(self, tags: list, version: str):
        # check_tags = all(item == tags[0] for item in tags)
        #
        # if check_tags is False or len(tags) == 0:
        #     raise Exception(f'ERROR: the Test Suite {{self.suite.name}} has different clauses or no clauses (Tags): {tags}\n'
        #                     f'Unable to select the corresponding Reference of this Test Suite')
        # else:
        #     # All the clauses are the same, so we select the first one
        #     reference = f'{{self.references[version]}}{tags[0].replace("_", ".")}'
        #     pics = f'PICS_{tags[0]}'
        #
        # return reference, pics
        aux = [x for x in tags if re.match(pattern='^(\d+_\d+_\d+)', string=x)]

        if len(aux) == 0:
            raise Exception(
                f'ERROR: the Test Suite {self.suite.name} has different clauses or no clauses (Tags): {tags}\n'
                f'Unable to select the corresponding Reference of this Test Suite')
        else:
            # All the clauses are the same, so we select the first one
            reference = f'{self.references[version]}{aux[0].replace("_", ".")}'
            pics = f'PICS_{aux[0]}'

        return reference, pics
