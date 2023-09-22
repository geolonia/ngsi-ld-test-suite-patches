import re


class ParseRobotFile:
    def __init__(self, filename: str, execdir: str):
        with open(filename, 'r') as file:
            # Read the contents of the file
            self.file_contents = file.read()

        self.variables = dict()
        self.execdir = execdir
        self.resource_file = str()

        self.get_variables_data()
        self.get_apiutils_path()

    def get_variables_data(self):
        string = self.get_substring(initial_string='*** Variables ***\n', final_string='*** ', include=False)

        regex = r"(\$\{.*\})\s*=\s*(.*)\n"

        matches = re.finditer(regex, string, re.MULTILINE)
        for match in matches:
            # Check that we have two groups matched
            if len(match.groups()) == 2:
                self.variables[match.group(1)] = match.group(2)
            else:
                print("Error, the variable is not following the format ${thing} = <value>")

    def get_expected_status_code(self, keyword: str):
        #     Check Response Status Code    ${expected_status_code}    ${response.status_code}
        #     Check Response Body Containing ProblemDetails Element Containing Type Element set to
        #     ...    ${response.json()}
        #     ...    ${ERROR_TYPE_LD_CONTEXT_NOT_AVAILABLE}
        string = self.get_substring(initial_string=keyword, final_string='\n', include=True)
        expected_status_code = string.split('    ')[1]

        if expected_status_code.isdigit():
            return expected_status_code
        else:
            return self.variables[expected_status_code]

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
                    print("Error, unexpected format")

            self.resource_file = self.resource_file.replace('${EXECDIR}', self.execdir)

    def get_substring(self, initial_string: str, final_string: str, include: bool) -> str:
        index_start = self.file_contents.find(initial_string)

        if include:
            string = self.file_contents[index_start:]
        else:
            string = self.file_contents[index_start+len(initial_string):]

        if final_string is not '':
            index_end = string.find(final_string)
            string = string[:index_end]

        return string
