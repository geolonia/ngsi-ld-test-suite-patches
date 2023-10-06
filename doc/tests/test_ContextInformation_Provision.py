#!/usr/bin/env python
from unittest import TestCase
from doc.analysis.generaterobotdata import GenerateRobotData
from json import load, dump
from deepdiff import DeepDiff
from os.path import dirname, exists
from os import listdir, remove, makedirs


class TestCIProvision(TestCase):
    @classmethod
    def setUpClass(cls):
        TestCIProvision.folder_test_suites = dirname(dirname(dirname(__file__)))
        folder_results = f'{TestCIProvision.folder_test_suites}/doc/results'

        # Check that the folder '/results' exists and if not, create it
        if not exists(folder_results):
            makedirs(folder_results)
        else:
            # Delete the /results folder
            [remove(f'{folder_results}/{x}') for x in listdir(folder_results) if x.startswith('out')]

    def setUp(self) -> None:
        self.folder_test_suites = dirname(dirname(dirname(__file__)))

    def common_function(self, robot_file, expected_value, difference_file):
        data = GenerateRobotData(robot_file=robot_file,
                                 execdir=self.folder_test_suites)
        data.parse_robot()
        obtained_response = data.get_info()

        with open(expected_value, 'r') as file:
            expected_response = load(file)

        result = DeepDiff(t1=obtained_response, t2=expected_response, ignore_order=True)

        if len(result) != 0:
            # There are some differences
            with open(difference_file, 'w') as fp:
                dump(obj=obtained_response, indent=2, fp=fp)

            assert False, f'They are some difference between the expected and obtained dictionaries: \n {result}'

    def test_003_01(self):
        self.fail("(003_01) Test Suite with Test Template, not yet implemented")

    def test_003_02(self):
        self.fail("(003_02) Test Suite result is wrong, need to be checked")

    def test_003_03(self):
        self.fail("(003_03) Test Suite with Test Template, not yet implemented")

    def test_003_04(self):
        self.fail("(003_04) Test Suite with 'Check Response Body Containing an Attribute set to' with different set of parameters")

    def test_003_05(self):
        self.fail("(003_05) Test Suite with 'Check Response Body Containing an Attribute set to' with different set of parameters")

    def test_003_06(self):
        robot_file = f'{self.folder_test_suites}/TP/NGSI-LD/ContextInformation/Provision/BatchEntities/CreateBatchOfEntities/003_06.robot'
        expected_value = f'{self.folder_test_suites}/doc/files/ContextInformation/Provision/003_06.json'
        difference_file = f'{self.folder_test_suites}/doc/results/out_003_06.json'

        self.common_function(robot_file=robot_file, expected_value=expected_value, difference_file=difference_file)

    def test_003_07(self):
        self.fail("(003_07) Test Suite with 'Check Response Body Containing an Attribute set to' with different set of parameters")

    def test_003_08(self):
        robot_file = f'{self.folder_test_suites}/TP/NGSI-LD/ContextInformation/Provision/BatchEntities/CreateBatchOfEntities/003_08.robot'
        expected_value = f'{self.folder_test_suites}/doc/files/ContextInformation/Provision/003_08.json'
        difference_file = f'{self.folder_test_suites}/doc/results/out_003_08.json'

        self.common_function(robot_file=robot_file, expected_value=expected_value, difference_file=difference_file)

    def test_003_09(self):
        robot_file = f'{self.folder_test_suites}/TP/NGSI-LD/ContextInformation/Provision/BatchEntities/CreateBatchOfEntities/003_09.robot'
        expected_value = f'{self.folder_test_suites}/doc/files/ContextInformation/Provision/003_09.json'
        difference_file = f'{self.folder_test_suites}/doc/results/out_003_09.json'

        self.common_function(robot_file=robot_file, expected_value=expected_value, difference_file=difference_file)

    def test_006_01(self):
        self.fail("(006_01) The first operation is not a setup operation of the environment but a Delete operation that have to be controlled")

    def test_006_02(self):
        self.fail("(006_02) The first operation is not a setup operation of the environment but a Delete operation that have to be controlled")

    def test_006_03(self):
        self.fail("(006_03) Test Suite with Test Template, not yet implemented")

    def test_005_01(self):
        self.fail("(005_01) Test Suite with Test Template, not yet implemented")

    def test_005_02(self):
        self.fail("(005_02) Test Suite with Test Template, not yet implemented")

    def test_005_03(self):
        self.fail("(005_03) Test Suite error content empty when generate then sentence")

    def test_005_04(self):
        self.fail("(005_04) Test Suite with Test Template, not yet implemented")

    def test_004_01(self):
        self.fail("(005_02) Test Suite with Test Template, not yet implemented")

    def test_004_02(self):
        self.fail("(004_02) Test Suite with Test Template, not yet implemented")

    def test_004_03(self):
        self.fail("(004_03) Test Suite with Test Template, not yet implemented")

    def test_004_04(self):
        self.fail("(004_04) Test Suite with Test Template, not yet implemented")

    def test_004_05(self):
        self.fail("(004_05) Test Suite error content empty when generate then sentence")

    def test_004_06(self):
        self.fail("(004_06) Test Suite with Test Template, not yet implemented")

    def test_001_01(self):
        self.fail("(001_01) Test Suite with Test Template, not yet implemented")

    def test_001_02(self):
        self.fail("(001_02) Test Suite with Test Template, not yet implemented")

    def test_001_03(self):
        robot_file = f'{self.folder_test_suites}/TP/NGSI-LD/ContextInformation/Provision/Entities/CreateEntity/001_03.robot'
        expected_value = f'{self.folder_test_suites}/doc/files/ContextInformation/Provision/001_03.json'
        difference_file = f'{self.folder_test_suites}/doc/results/out_001_03.json'

        self.common_function(robot_file=robot_file, expected_value=expected_value, difference_file=difference_file)

    def test_001_04(self):
        self.fail("(001_04) Test Suite with 'Check Response Body Containing an Attribute set to' with different set of parameters")

    def test_001_05(self):
        robot_file = f'{self.folder_test_suites}/TP/NGSI-LD/ContextInformation/Provision/Entities/CreateEntity/001_05.robot'
        expected_value = f'{self.folder_test_suites}/doc/files/ContextInformation/Provision/001_05.json'
        difference_file = f'{self.folder_test_suites}/doc/results/out_001_05.json'

        self.common_function(robot_file=robot_file, expected_value=expected_value, difference_file=difference_file)

    def test_001_06(self):
        robot_file = f'{self.folder_test_suites}/TP/NGSI-LD/ContextInformation/Provision/Entities/CreateEntity/001_06.robot'
        expected_value = f'{self.folder_test_suites}/doc/files/ContextInformation/Provision/001_06.json'
        difference_file = f'{self.folder_test_suites}/doc/results/out_001_06.json'

        self.common_function(robot_file=robot_file, expected_value=expected_value, difference_file=difference_file)

    def test_001_07(self):
        self.fail("(001_07) Test Suite with 'Check Response Body Containing an Attribute set to' with different set of parameters")

    def test_001_08(self):
        robot_file = f'{self.folder_test_suites}/TP/NGSI-LD/ContextInformation/Provision/Entities/CreateEntity/001_08.robot'
        expected_value = f'{self.folder_test_suites}/doc/files/ContextInformation/Provision/001_08.json'
        difference_file = f'{self.folder_test_suites}/doc/results/out_001_08.json'

        self.common_function(robot_file=robot_file, expected_value=expected_value, difference_file=difference_file)

    def test_001_09(self):
        robot_file = f'{self.folder_test_suites}/TP/NGSI-LD/ContextInformation/Provision/Entities/CreateEntity/001_09.robot'
        expected_value = f'{self.folder_test_suites}/doc/files/ContextInformation/Provision/001_09.json'
        difference_file = f'{self.folder_test_suites}/doc/results/out_001_09.json'

        self.common_function(robot_file=robot_file, expected_value=expected_value, difference_file=difference_file)

    def test_002_01(self):
        self.fail("(002_01) Test Suite, something wrong with two different Checks")

    def test_002_02(self):
        self.fail("(002_02) Test Suite with Test Template, not yet implemented")

    def test_002_03(self):
        robot_file = f'{self.folder_test_suites}/TP/NGSI-LD/ContextInformation/Provision/Entities/DeleteEntity/002_03.robot'
        expected_value = f'{self.folder_test_suites}/doc/files/ContextInformation/Provision/002_03.json'
        difference_file = f'{self.folder_test_suites}/doc/results/out_002_03.json'

        self.common_function(robot_file=robot_file, expected_value=expected_value, difference_file=difference_file)
