#!/usr/bin/env python
from unittest import TestCase
from doc.analysis.generaterobotdata import GenerateRobotData
from json import load, dump
from deepdiff import DeepDiff
from os.path import dirname, exists
from os import listdir, remove, makedirs


class TestCIConsumptions(TestCase):
    @classmethod
    def setUpClass(cls):
        TestCIConsumptions.folder_test_suites = dirname(dirname(dirname(__file__)))
        folder_results = f'{TestCIConsumptions.folder_test_suites}/doc/results'

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

    def test_027_01(self):
        robot_file = f'{self.folder_test_suites}/TP/NGSI-LD/ContextInformation/Consumption/Discovery/RetrieveAvailableAttributeInformation/027_01.robot'
        expected_value = f'{self.folder_test_suites}/doc/files/027_01.json'
        difference_file = f'{self.folder_test_suites}/doc/results/out_027_01.json'

        self.common_function(robot_file=robot_file, expected_value=expected_value, difference_file=difference_file)

    def test_027_02(self):
        robot_file = f'{self.folder_test_suites}/TP/NGSI-LD/ContextInformation/Consumption/Discovery/RetrieveAvailableAttributeInformation/027_02.robot'
        expected_value = f'{self.folder_test_suites}/doc/files/027_02.json'
        difference_file = f'{self.folder_test_suites}/doc/results/out_027_02.json'

        self.common_function(robot_file=robot_file, expected_value=expected_value, difference_file=difference_file)

    def test_024_01(self):
        robot_file = f'{self.folder_test_suites}/TP/NGSI-LD/ContextInformation/Consumption/Discovery/RetrieveAvailableEntityTypeInformation/024_01.robot'
        expected_value = f'{self.folder_test_suites}/doc/files/024_01.json'
        difference_file = f'{self.folder_test_suites}/doc/results/out_024_01.json'

        self.common_function(robot_file=robot_file, expected_value=expected_value, difference_file=difference_file)

    def test_024_02(self):
        robot_file = f'{self.folder_test_suites}/TP/NGSI-LD/ContextInformation/Consumption/Discovery/RetrieveAvailableEntityTypeInformation/024_02.robot'
        expected_value = f'{self.folder_test_suites}/doc/files/024_02.json'
        difference_file = f'{self.folder_test_suites}/doc/results/out_024_02.json'

        self.common_function(robot_file=robot_file, expected_value=expected_value, difference_file=difference_file)

    def test_019_01_01(self):
        robot_file = f'{self.folder_test_suites}/TP/NGSI-LD/ContextInformation/Consumption/Entity/QueryEntities/019_01_01.robot'
        expected_value = f'{self.folder_test_suites}/doc/files/019_01_01.json'
        difference_file = f'{self.folder_test_suites}/doc/results/out_019_01_01.json'

        self.common_function(robot_file=robot_file, expected_value=expected_value, difference_file=difference_file)
