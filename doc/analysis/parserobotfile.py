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

        self.get_variables_data()
        self.get_apiutils_path()
        self.get_test_cases()

        self.config_file = config_file

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
        index_start = self.file_contents.find('*** Test Cases ***')
        string = self.file_contents[index_start+len('*** Test Cases ***')+1:]

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

    def get_checks(self, test_name, apiutils):
        data = Checks()

        test_content = self.test_cases[test_name]

        # Get The lines starting by 'Check'
        checks = list()
        param = dict()
        # lines_starting_with_check = re.findall(r'^\s*Check.*', test_content, re.MULTILINE)
        lines_starting_with_check = self.get_lines_with_checks(content=test_content)
        for line in lines_starting_with_check:
            check, param = self.get_data_check(test_case=test_content, checks=data, line=line)
            result = data.get_checks(checks=check, **param)
            checks.append(result)

        result = self.generate_then_content(content=checks)

        return result

    def get_lines_with_checks(self, content):
        # Obtain the complete list of lines that contains a Check
        lines_starting_with_check = re.findall(r'^\s*Check.*', content, re.MULTILINE)

        # From the list of Checks, we need to discard all 'Check Response Status Code' except the last one
        check_string = 'Check Response Status Code'
        lines_starting_with_check = [x.strip() for x in lines_starting_with_check]
        new_list = [value for value in lines_starting_with_check if not value.startswith(check_string)]
        abb_values = [value for value in lines_starting_with_check if value.startswith(check_string)]

        if abb_values:
            new_list.append(abb_values[-1])

        return new_list

    def get_request(self, test_name):
        data = Requests(variables=self.variables,
                        apiutils_variables=self.apiutils.variables,
                        config_file=self.config_file)
        description = data.get_description(string=self.test_cases[test_name])
        return description

    def generate_then_content(self, content):
        if len(content) > 1:
            checks = " and\n        ".join(content)
            checks = f"then {{\n    the SUT sends a valid Response containing:\n        {checks}\n}}"
        elif len(content) == 1:
            checks = f"then {{\n    the SUT sends a valid Response containing:\n        {content[0]}\n}}"
        else:
            raise Exception("ERROR, It is expected at least 1 Check operation in the Test Case")

        return checks

    def generate_when_content(self, http_verb, endpoint, when):
        url = f"URL set to '/ngsi-ld/v1/{endpoint}'"
        method = f"method set to '{http_verb}'"
        when = (f"when {{\n    the SUT receives a Request from the client containing:\n"
                f"        {url}\n"
                f"        {method}\n"
                f"        {when}")

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

        for i in range(0, len(params['position'])):
            param_key = params['params'][i]
            param_position = params['position'][i]
            # param_value = self.variables[content[param_position]]
            param_value = self.get_param_value(position=content[param_position])
            result[param_key] = param_value

        return result

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
        try:
            result = self.variables[position]
        except KeyError:
            try:
                result = self.apiutils.variables[position]
            except KeyError:
                result = position

        return result
