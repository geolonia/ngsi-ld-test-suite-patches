from pathlib import Path
from robot.running import TestDefaults, TestSuite
from robot.api import SuiteVisitor
from robot.model.testcase import TestCase
from pprint import pprint
from os import getcwd


class TestDataVisitor(SuiteVisitor):
    def __init__(self):
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
        self.base_TP_id = str()

    def get_test_data(self, tests: TestCase):
        pass

    def start_suite(self, suite):
        """Modify suite's tests to contain only every Xth."""
        version = 'v1.3.1'
        tp_id = self.generate_name(suite_data=suite)
        reference, pics = self.generate_reference(suite_data=suite, version=version)

        self.test_suite = {
            'tp_id': tp_id,
            'test_objective': suite.doc,
            'reference': reference,
            'config_id': '',
            'parent_release': version,
            'pics_selection': pics,
            'keywords': suite.keywords,
            'teardown': suite.teardown,
            'initial_condition': suite.setup,
            'test_cases': list()
        }

    def end_suite(self, suite):
        """Remove suites that are empty after removing tests."""
        self.test_suite['test_cases'] = self.test_cases

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

    def generate_name(self, suite_data):
        current_path = getcwd()
        TP_id = str(suite_data.source.parent)[len(current_path):]

        if TP_id[0:4] == '/../':
            TP_id = TP_id[4:]

        for key, value in self.identifier.items():
            TP_id = TP_id.replace(key, value)

        self.base_TP_id = TP_id
        print(self.base_TP_id)

        name = suite_data.name.replace(" ", "_")
        TP_id = f'{self.base_TP_id}/{name}'

        return TP_id

    def generate_reference(self, suite_data, version):
        ref = f'{self.references[version]}'

        # Get the list of tags in the different tests
        aux = [x.tags for x in suite_data.tests]
        aux = [element for sublist in aux for element in sublist if element[0].isdigit()]
        check_tags = all(item == aux[0] for item in aux)

        if check_tags is False or len(aux) == 0:
            print(f'ERROR: the Test Suite {suite_data.name} has different clauses or no clauses (Tags): {aux}\n'
                  f'Unable to select the corresponding Reference of this Test Suite')
            reference = ''
            pics = ''
        else:
            # All the clauses are the same, so we select the first one
            reference = f'{self.references[version]}{aux[0].replace("_", ".")}'
            pics = f'PICS_{aux[0]}'

        return reference, pics


class RobotPreprocessor:
    extension = '.robot'

    def __init__(self, source: 'Path|str', defaults: TestDefaults):
        self.source = source
        self.defaults = defaults
        self.suite = TestSuite.from_file_system(source)
        self.visitor = TestDataVisitor()

    def parse(self) -> TestSuite:
        d = self.source.read_text()
        for header in 'Settings', 'Variables', 'Test Cases', 'Keywords':
            d = d.replace(f'=== {header} ===', f'*** {header} ***')
        suite = TestSuite.from_string(d, defaults=self.defaults)
        return suite.config(name=TestSuite.name_from_source(self.source), source=self.source)

    def convert_robot_file_to_json(self):
        self.suite.visit(self.visitor)
        return self.visitor.test_suite


robot_file = '../TP/NGSI-LD/ContextInformation/Consumption/Entity/RetrieveEntity/018_06.robot'
path_file = Path(robot_file)

parse = RobotPreprocessor(source=path_file, defaults=TestDefaults())
data = parse.convert_robot_file_to_json()
pprint(data)



robot_file = '../TP/NGSI-LD/CommonBehaviours/043.robot'
path_file = Path(robot_file)

parse = RobotPreprocessor(source=path_file, defaults=TestDefaults())
data = parse.convert_robot_file_to_json()
pprint(data)
