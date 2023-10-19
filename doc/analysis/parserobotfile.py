import re
import os
from analysis.checks import Checks
from analysis.requests import Requests


class ParseRobotFile:
    def __init__(self, filename: str, execdir: str, config_file):
        self.test_suite = os.path.basename(filename).split('.')[0]

        with open(filename, 'r') as file:
            # Read the contents of the file
            self.file_contents = file.read()

        self.variables = dict()
        self.execdir = execdir
        self.resource_file = str()
        self.apiutils = None

        self.string_test_template = str()
        self.test_template_name = str()
        self.template_params_value = dict()
        self.check_template()

        self.get_variables_data()
        self.get_apiutils_path()
        self.get_test_cases()

        self.config_file = config_file

    def check_template(self):
        # Check if there is a template and which template we have
        aux = re.findall(pattern=r'Test Template[ ]+(.*)', string=self.file_contents)

        if len(aux) != 0:
            self.test_template_name = aux[0]
        else:
            self.test_template_name = ''

    def set_apiutils(self, apiutils):
        self.apiutils = apiutils

    def get_variables_data(self):
        string = self.get_substring(initial_string='*** Variables ***\n', final_string='*** ', include=False)

        regex = r"(\$\{.*\})\s*=\s*(.*)\n"

        matches = re.finditer(regex, string, re.MULTILINE)
        for match in matches:
            # Check that we have two groups matched
            if len(match.groups()) == 2:
                self.variables[match.group(1)] = match.group(2)
            else:
                raise Exception("Error, the variable is not following the format ${thing} = <value>")

    def get_apiutils_path(self):
        string = self.get_substring(initial_string='Resource', final_string='*** Variables ***', include=True)
        result = [item for item in string.split('\n') if 'ApiUtils.resource' in item and item[0] != '#']

        if len(result) == 1:
            regex = r"\s*Resource\s*(.*)\s*"

            matches = re.finditer(regex, result[0], re.MULTILINE)
            for match in matches:
                # Check that we have 1 group matched
                if len(match.groups()) == 1:
                    self.resource_file = match.group(1)
                else:
                    raise Exception("Error, unexpected format")

            self.resource_file = self.resource_file.replace('${EXECDIR}', self.execdir)

    def get_substring(self, initial_string: str, final_string: str, include: bool) -> str:
        index_start = self.file_contents.find(initial_string)

        if include:
            string = self.file_contents[index_start:]
        else:
            string = self.file_contents[index_start+len(initial_string):]

        if final_string != '':
            index_end = string.find(final_string)
            string = string[:index_end]

        return string

    def get_test_cases(self):
        if self.test_template_name == '':
            self.get_test_cases_without_template()
        else:
            self.get_test_cases_with_template()

    def get_test_cases_with_template(self):
        # In case of template, we have to get the value of the tags and the parameters value from the Test Cases and
        # the content of the operations from the corresponding Keyword content corresponding to the Test Template
        index_start_test_cases = self.file_contents.find('*** Test Cases ***')
        index_start_keywords = self.file_contents.find('*** Keywords ***')

        string_test_cases = self.file_contents[index_start_test_cases+len('*** Test Cases ***')+1:index_start_keywords]
        self.string_test_template = self.file_contents[index_start_keywords+len('*** Keywords ***')+1:]

        self.get_test_cases_content(string=string_test_cases)
        self.get_template_param_values(test_cases=string_test_cases)

    def get_template_param_values(self, test_cases):
        # Extract the parameter of the Test Cases
        # the first line is the argument of the test case
        params = test_cases.split("\n")[0].strip().split("    ")
        params = [x.lower() for x in params]

        # Obtain the params values
        keys = self.test_cases.keys()
        data = self.test_cases

        for k in keys:
            aux = data[k]
            aux = aux.split('\n')[1:]
            aux = [x.strip() for x in aux if x.find("[Tags]") == -1][0]
            aux = aux.split("    ")

            result = [{f"${{{k}}}": v} for k, v in zip(params, aux)]
            result = {k: v for d in result for k, v in d.items()}

            self.template_params_value[k] = result

    def get_test_cases_content(self, string):
        pattern = f'{self.test_suite}_\d+\s.*'
        matches = re.findall(pattern=pattern, string=string)

        indexes = list()
        self.test_case_names = list()
        if matches:
            for match in matches:
                name = match.strip()
                self.test_case_names.append(name)
                indexes.append(string.find(name))
        else:
            # The test case has the same id. number as the test suite
            pattern = f'{self.test_suite}\s.*'
            matches = re.findall(pattern=pattern, string=string)

            for match in matches:
                name = match.strip()
                self.test_case_names.append(name)
                indexes.append(string.find(name))

        self.test_cases = dict()
        for i in range(0, len(indexes)-1):
            self.test_cases[self.test_case_names[i]] = string[indexes[i]:indexes[i+1]]

        try:
            self.test_cases[self.test_case_names[-1]] = string[indexes[-1]:]
        except IndexError:
            raise Exception(f"ERROR, List index out of range, "
                            f"probably the name of the Test Case is not following the pattern '{pattern}'")

    def get_test_cases_without_template(self):
        index_start = self.file_contents.find('*** Test Cases ***')
        string = self.file_contents[index_start+len('*** Test Cases ***')+1:]

        self.get_test_cases_content(string=string)

    def get_text_cases_content(self, name: str):
        if self.test_template_name == '':
            result = self.test_cases[name]
        else:
            result = self.string_test_template

        return result

    def get_checks(self, test_name, apiutils):
        data = Checks()
        self.test_name = test_name

        # test_content = self.test_cases[test_name]
        test_content = self.get_text_cases_content(name=test_name)

        # Get The lines starting by 'Check'
        checks = list()
        param = dict()
        lines_starting_with_check = self.get_lines_with_checks(content=test_content)
        for line in lines_starting_with_check:
            check, param = self.get_data_check(test_case=test_content, checks=data, line=line)
            result = data.get_checks(checks=check, **param)
            checks.append(result)

        result = self.generate_then_content(content=checks)

        return result

    def get_lines_with_checks(self, content):
        new_list = list()

        # Obtain the complete list of lines that contains a Check
        lines_starting_with_check = re.findall(r'^\s*Check.*', content, re.MULTILINE)

        if len(lines_starting_with_check) != 0:
            # TODO: From the list of Checks, we need to discard all 'Check Response Status Code' except the last one. Should be respolve when clearly defined the Setup process of the Test Suite
            check_string = 'Check Response Status Code'
            lines_starting_with_check = [x.strip() for x in lines_starting_with_check]
            new_list = [value for value in lines_starting_with_check if not value.startswith(check_string)]
            abb_values = [value for value in lines_starting_with_check if value.startswith(check_string)]

            if abb_values:
                new_list.append(abb_values[-1])
        elif content.find('Wait for notification') != 0:
            # There is no Check, we need to check if there is a 'Wait for notification',
            # then we need to check the 'Should be Equal' sentences
            param = re.findall(r'Wait for notification\s{4}(.*)', content, re.MULTILINE)
            new_list.append(f'Wait for notification    {param[0]}')
            lines_starting_with_should = re.findall(r'^\s*Should be Equal.*', content, re.MULTILINE)
            _ = [new_list.append(x.strip()) for x in lines_starting_with_should]

        return new_list

    def get_request(self, test_name):
        data = Requests(variables=self.variables,
                        apiutils_variables=self.apiutils.variables,
                        config_file=self.config_file,
                        template_params_value=self.template_params_value,
                        test_name=test_name)

        if self.test_template_name == '':
            description = data.get_description(string=self.test_cases[test_name])
        else:
            description = data.get_description(string=self.string_test_template)

        return description

    def generate_then_content(self, content):
        # Need to check if it is a Notification data or a normal Response
        aux = [x for x in content if x.find('Notification data') != -1 or x.find('After waiting') != -1]

        if len(aux) == 0:
            # The SUT sends a valid Response
            if len(content) > 1:
                checks = " and\n        ".join(content)
                checks = f"then {{\n    the SUT sends a valid Response containing:\n        {checks}\n}}"
            elif len(content) == 1:
                checks = f"then {{\n    the SUT sends a valid Response containing:\n        {content[0]}\n}}"
            else:
                raise Exception("ERROR, It is expected at least 1 Check operation in the Test Case")
        else:
            # The Client receives a valid Notification
            if len(content) > 1:
                checks = " and\n        ".join(content)
                checks = (f"then {{\n    the client at '${{endpoint}}' receives a valid Notification containing:\n"
                          f"        {checks}\n}}")
            elif len(content) == 1:
                checks = (f"then {{\n    the client at '${{endpoint}}' receives a valid Notification, {content[0]}\n}}")
            else:
                raise Exception("ERROR, It is expected at least 1 Notification Check operation in the Test Case")

        return checks

    def generate_when_content(self, http_verb, endpoint, when):
        url = f"URL set to '/ngsi-ld/v1/{endpoint}'"
        method = f"method set to '{http_verb}'"
        when = (f"when {{\n    the SUT receives a Request from the client containing:\n"
                f"        {url}\n"
                f"        {method}\n"
                f"        {when}\n"
                f"}}")

        return when

    def get_data_check(self, test_case, checks, line):
        content = line.split("    ")
        aux = len(content)

        try:
            position_params = checks.args[content[0]]
            if aux == 1:
                # We are in multiline classification of the Check, need to extract the parameter for the next lines
                params = self.find_attributes_next_line(test_case=test_case, name=content[0],
                                                        position_params=position_params)
                return content[0], params
            elif aux > 1:
                # We are in one line definition
                params = self.find_attributes_same_line(params=position_params, content=content)
                return content[0], params
            else:
                raise Exception("ERROR, line should contain data")
        except KeyError:
            # The Check operation does not require parameters
            return content[0], dict()

    def find_attributes_same_line(self, params, content):
        result = dict()

        if len(params['position']) > 0:
            for i in range(0, len(params['position'])):
                param_key = params['params'][i]
                param_position = params['position'][i]
                param_value = self.get_param_value(position=content[param_position])
                result[param_key] = param_value
        elif len(params['position']) == 0:
            param_key = params['params'][0]
            param_value = self.get_param_value_for_waiting(param_key=param_key, content=content)
            result[param_key] = param_value

        return result

    def get_param_value_for_waiting(self, param_key, content):
        found = [x for x in content if x.find(param_key) != -1]
        length = len(found)

        if length != 0:
            found = found[0]

            if found.find('=') != -1:
                # in the format variable=value
                pattern = f"{param_key}=\${{(\d+)}}"
        elif length == 0 and len(content) > 1:
            # There is params but they are not written in the form key=value
            found = content[1]
            pattern = f"\${{(\d+)}}"

        value = re.match(pattern=pattern, string=found)

        try:
            value = value.group(1)
        except AttributeError:
            value = ''

        return value

    def find_attributes_next_line(self, test_case, name, position_params):
        index_start = test_case.find(name)

        aux = test_case[index_start+len(name)+1:].split('\n')

        params = list()
        for a in range(0, len(aux)):
            param = aux[a]
            if param.startswith("    ..."):
                params.append(param.split('    ')[-1])
            else:
                break

        param = dict()
        for i in range(0, len(position_params['position'])):
            param_key = position_params['params'][i]
            param_position = position_params['position'][i]
            param_value = self.get_param_value(position=params[param_position-1])
            param[param_key] = param_value

        return param

    def get_param_value(self, position):
        # try:
        #     # Check if we can get the data from the current robot files
        #     result = self.variables[position]
        # except KeyError:
        #     try:
        #         # Check if we can get the data from the apiutils file
        #         result = self.apiutils.variables[position]
        #     except KeyError:
        #         try:
        #             # Check if we can get the data from the template
        #             aux = self.template_params_value[self.test_name]
        #             result = aux[position]
        #         except KeyError:
        #             result = position
        #
        # return result
        try:
            # Check if we can get the data from the current robot files
            result = self.variables[position]
        except KeyError:
            try:
                # Check if we can get the data from the apiutils file
                result = self.apiutils.variables[position]
            except KeyError:
                try:
                    aux = re.findall(pattern=r'\$\{(.*)}', string=position)
                    if len(aux) != 0:
                        aux = aux[0]
                    else:
                        aux = position
                    result = self.config_file.get_variable(aux)
                except KeyError:
                    try:
                        aux = self.template_params_value[self.test_name]
                        result = aux[position]

                        if result[:2] == "${":
                            result = self.get_param_value(result)
                    except KeyError:
                        result = position

        return result
