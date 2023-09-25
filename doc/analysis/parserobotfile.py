import re
import os
from doc.analysis.checks import Checks


class ParseRobotFile:
    def __init__(self, filename: str, execdir: str):
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

    # def get_expected_status_code(self, keyword: str):
    #     #     Check Response Status Code    ${expected_status_code}    ${response.status_code}
    #     #     Check Response Body Containing ProblemDetails Element Containing Type Element set to
    #     #     ...    ${response.json()}
    #     #     ...    ${ERROR_TYPE_LD_CONTEXT_NOT_AVAILABLE}
    #     string = self.get_substring(initial_string=keyword, final_string='\n', include=True)
    #     expected_status_code = string.split('    ')[1]
    #
    #     if expected_status_code.isdigit():
    #         return expected_status_code
    #     else:
    #         return self.variables[expected_status_code]

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
        for match in matches:
            name = match.strip()
            self.test_case_names.append(name)
            indexes.append(string.find(name))

        self.test_cases = dict()
        for i in range(0, len(indexes)-1):
            self.test_cases[self.test_case_names[i]] = string[indexes[i]:indexes[i+1]]

        self.test_cases[self.test_case_names[-1]] = string[indexes[-1]:]

    def get_checks(self, test_name, apiutils):
        data = Checks()

        test_content = self.test_cases[test_name]

        # Get The lines starting by 'Check'
        checks = list()
        param = dict()
        lines_starting_with_check = re.findall(r'^\s*Check.*', test_content, re.MULTILINE)
        for line in lines_starting_with_check:
            check, param = self.get_data_check(test_case=test_content, checks=data, line=line.strip())
            result = data.get_checks(checks=check, **param)
            checks.append(result)

        result = self.generate_then_content(content=checks)

        return result

    def generate_then_content(self, content):
        if len(content) > 1:
            checks = " and\n        ".join(content)
            checks = f"then {{\n    the SUT sends a valid Response containing:\n        {checks}\n}}"
        elif len(content) == 1:
            checks = f"then {{\n    the SUT sends a valid Response containing:\n        {content[0]}\n}}"
        else:
            raise Exception("ERROR, It is expected at least 1 Check operation in the Test Case")

        return checks

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
                # We are in one line definiton
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
            # param_value = self.variables[params[param_position]-1]
            param_value = self.get_param_value(position=params[param_position-1])
            param[param_key] = param_value

        return param

    def get_param_value(self, position):
        try:
            result = self.variables[position]
        except KeyError:
            result = self.apiutils.variables[position]

        return result