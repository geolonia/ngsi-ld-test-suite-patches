from os.path import join
from os import getcwd
from re import compile, match, MULTILINE


class ErrorListener:
    ROBOT_LISTENER_API_VERSION = 2

    def __init__(self, filename='errors.log'):
        self.cwd = getcwd()
        out_path = join('results', filename)
        self.max_length = 150
        self.outfile = open(out_path, 'w')
        self.tests = str()
        self.suite_name = str()
        self.rx_dict = {
            'variables': compile('^\${.*$|^\&{.*$|^\@{.*'),
            'http_verbs': compile('^GET.*(Request|Response).*$|'
                                  '^HEAD.*(Request|Response).*$|'
                                  '^POST.*(Request|Response).*$|'
                                  '^PUT.*(Request|Response).*$|'
                                  '^DELETE.*(Request|Response).*$|'
                                  '^CONNECT.*(Request|Response).*$|'
                                  '^OPTIONS.*(Request|Response).*$|'
                                  '^TRACE.*(Request|Response).*$|'
                                  '^PATCH.*(Request|Response).*$', MULTILINE)
        }

    def start_suite(self, name, attrs):
        self.suite_name = attrs['source'].replace(self.cwd, '')[1:].replace('.robot', '').replace('/', ".")
        self.outfile.write(f'{"=" * self.max_length}\n')
        self.outfile.write(f'{self.suite_name} :: {attrs["doc"]}\n')
        self.outfile.write(f'{"=" * self.max_length}\n')

    def start_test(self, name, attrs):
        self.tests = f"{name} :: {attrs['doc']}\n"

    def end_test(self, name, attrs):
        if attrs['status'] != 'PASS':
            self.outfile.write(self.tests)
            self.outfile.write(f'| FAIL |\n{attrs["message"]}\n')
            self.outfile.write(f'{"-" * self.max_length}\n')

    def end_suite(self, name, attrs):
        self.outfile.write(f'{self.suite_name} :: {attrs["doc"]}... | {attrs["status"]} |\n{attrs["statistics"]}\n')

    def log_message(self, msg):
        if (not match(pattern=self.rx_dict['variables'], string=msg['message']) and
                not match(pattern=self.rx_dict['http_verbs'], string=msg['message'])):
            self.outfile.write(f'{msg["message"]}\n')

    def close(self):
        self.outfile.close()
