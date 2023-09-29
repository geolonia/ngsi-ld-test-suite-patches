import re


class ParseApiUtilsFile:
    def __init__(self, filename: str):
        with open(filename, 'r') as file:
            # Read the contents of the file
            self.file_contents = file.read()

        self.variables = dict()

        self.get_variables_data()

    def get_response(self, keyword):
        verb = str()
        url = list()

        string = self.get_substring(initial_string=keyword, final_string='RETURN', include=True)
        index = string.find('    ${response}')
        string = string[index:]
        string = string.split('\n')

        index = None
        for i, item in enumerate(string):
            if 'response' in item:
                regex = "\s{4}\$\{response\}=\s{4}(POST|GET|PUT|PATCH|DELETE).*"
                match = re.match(pattern=regex, string=item)

                if match:
                    verb = match.groups()[0]

            if 'url' in item:
                #url = item.split('/')[1]
                url = self.get_url_request(url=item)

        return verb, url

    @staticmethod
    def get_url_request(url: str) -> list:
        # We have two options, the url is defined in the same line of the response or it is defined in the following
        # lines with '...'
        keys = list()

        if 'response' in url:
            url = [x for x in url.split('    ') if 'url' in x][0]

        regex = r"\s*\.*\s*url=\$\{url\}\/(.*)"

        match = re.match(pattern=regex, string=url)
        if match:
            aux = match.groups()[0]
            keys = re.split(r'\$|/', aux)
            keys = [k for k in keys if k != '']

        return keys

    def get_variables_data(self):
        string = self.get_substring(initial_string='*** Variables ***\n', final_string='*** ', include=False)

        regex = "(\$\{.*\})\s*(.*)\n"

        matches = re.finditer(regex, string, re.MULTILINE)
        for match in matches:
            # Check that we have two groups matched
            if len(match.groups()) == 2:
                if match.group(1) not in self.variables.keys():
                    self.variables[match.group(1)] = match.group(2)
            else:
                raise Exception("Error, the variable is not following the format ${thing} = <value>")

    def get_substring(self, initial_string: str, final_string: str, include: bool) -> str:
        index_start = self.file_contents.find(initial_string)

        if include:
            string = self.file_contents[index_start:]
        else:
            string = self.file_contents[index_start+len(initial_string):]

        index_end = string.find(final_string)
        string = string[:index_end]

        return string
