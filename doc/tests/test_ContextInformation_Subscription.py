#!/usr/bin/env python
from unittest import TestCase
from doc.analysis.generaterobotdata import GenerateRobotData
from json import load, dump
from deepdiff import DeepDiff
from os.path import dirname, exists
from os import listdir, remove, makedirs


class TestCISubscription(TestCase):
    @classmethod
    def setUpClass(cls):
        TestCISubscription.folder_test_suites = dirname(dirname(dirname(__file__)))
        folder_results = f'{TestCISubscription.folder_test_suites}/doc/results'

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

    def test_028_01(self):
        robot_file = f'{self.folder_test_suites}/TP/NGSI-LD/ContextInformation/Subscription/CreateSubscription/028_01.robot'
        expected_value = f'{self.folder_test_suites}/doc/files/ContextInformation/Subscription/028_01.json'
        difference_file = f'{self.folder_test_suites}/doc/results/out_028_01.json'

        self.common_function(robot_file=robot_file, expected_value=expected_value, difference_file=difference_file)

    def test_028_02(self):
        self.fail("(028_02) Test Suite with Test Template, not yet implemented")

    def test_028_03(self):
        self.fail("(028_03) Test Suite with Test Template, not yet implemented")

    def test_028_04(self):
        robot_file = f'{self.folder_test_suites}/TP/NGSI-LD/ContextInformation/Subscription/CreateSubscription/028_04.robot'
        expected_value = f'{self.folder_test_suites}/doc/files/ContextInformation/Subscription/028_04.json'
        difference_file = f'{self.folder_test_suites}/doc/results/out_028_04.json'

        self.common_function(robot_file=robot_file, expected_value=expected_value, difference_file=difference_file)

    def test_032_01(self):
        self.fail("(032_01) Test Suite with Test Template, not yet implemented")

    def test_032_02(self):
        robot_file = f'{self.folder_test_suites}/TP/NGSI-LD/ContextInformation/Subscription/DeleteSubscription/032_02.robot'
        expected_value = f'{self.folder_test_suites}/doc/files/ContextInformation/Subscription/032_02.json'
        difference_file = f'{self.folder_test_suites}/doc/results/out_032_02.json'

        self.common_function(robot_file=robot_file, expected_value=expected_value, difference_file=difference_file)

    def test_032_03(self):
        self.fail("(032_03) Test Suite need to know which is the document to be generated")

    def test_046_01(self):
        robot_file = f'{self.folder_test_suites}/TP/NGSI-LD/ContextInformation/Subscription/Notification/046_01.robot'
        expected_value = f'{self.folder_test_suites}/doc/files/ContextInformation/Subscription/046_01.json'
        difference_file = f'{self.folder_test_suites}/doc/results/out_046_01.json'

        self.common_function(robot_file=robot_file, expected_value=expected_value, difference_file=difference_file)
        self.fail("(046_01) Test Suite need to change the Initial Conditions")

    def test_046_02(self):
        self.fail("(046_02) Test Suite need to change the Initial Conditions")

    def test_046_03(self):
        self.fail("(046_03) Test Suite need to change the Initial Conditions")

    def test_046_04(self):
        self.fail("(046_04) Test Suite ERROR")

    def test_046_05(self):
        self.fail("(046_05) Test Suite need to change the Initial Conditions")

    def test_046_06(self):
        self.fail("(046_06) Test Suite need to change the Initial Conditions")

    def test_046_07(self):
        self.fail("(046_07) Test Suite ERROR")

    def test_046_08(self):
        self.fail("(046_08) Test Suite need to change the Initial Conditions")

    def test_046_09(self):
        self.fail("(046_09) Test Suite ERROR")

    def test_046_10(self):
        self.fail("(046_10) Test Suite need to change the Initial Conditions")

    def test_046_11(self):
        self.fail("(046_11) Test Suite ERROR")

    def test_046_12(self):
        self.fail("(046_12) Test Suite need to change the Initial Conditions")

    def test_046_13(self):
        self.fail("(046_13) Test Suite need to change the Initial Conditions")

    def test_046_14(self):
        self.fail("(046_14) Test Suite need to change the Initial Conditions")

    def test_031_01(self):
        robot_file = f'{self.folder_test_suites}/TP/NGSI-LD/ContextInformation/Subscription/QuerySubscriptions/031_01.robot'
        expected_value = f'{self.folder_test_suites}/doc/files/ContextInformation/Subscription/031_01.json'
        difference_file = f'{self.folder_test_suites}/doc/results/out_031_01.json'

        self.common_function(robot_file=robot_file, expected_value=expected_value, difference_file=difference_file)

    def test_031_02(self):
        self.fail("(031_02) Test Suite with Test Template, not yet implemented")

    def test_030_01(self):
        self.fail("(031_02) Test Suite with Test Template, not yet implemented")

    def test_030_02(self):
        robot_file = f'{self.folder_test_suites}/TP/NGSI-LD/ContextInformation/Subscription/RetrieveSubscription/030_02.robot'
        expected_value = f'{self.folder_test_suites}/doc/files/ContextInformation/Subscription/030_02.json'
        difference_file = f'{self.folder_test_suites}/doc/results/out_030_02.json'

        self.common_function(robot_file=robot_file, expected_value=expected_value, difference_file=difference_file)

    def test_029_01(self):
        self.fail("(029_01) Test Suite with Test Template, not yet implemented")

    def test_029_02(self):
        robot_file = f'{self.folder_test_suites}/TP/NGSI-LD/ContextInformation/Subscription/UpdateSubscription/029_02.robot'
        expected_value = f'{self.folder_test_suites}/doc/files/ContextInformation/Subscription/029_02.json'
        difference_file = f'{self.folder_test_suites}/doc/results/out_029_02.json'

        self.common_function(robot_file=robot_file, expected_value=expected_value, difference_file=difference_file)

    def test_029_03(self):
        robot_file = f'{self.folder_test_suites}/TP/NGSI-LD/ContextInformation/Subscription/UpdateSubscription/029_03.robot'
        expected_value = f'{self.folder_test_suites}/doc/files/ContextInformation/Subscription/029_03.json'
        difference_file = f'{self.folder_test_suites}/doc/results/out_029_03.json'

        self.common_function(robot_file=robot_file, expected_value=expected_value, difference_file=difference_file)

    def test_029_04(self):
        robot_file = f'{self.folder_test_suites}/TP/NGSI-LD/ContextInformation/Subscription/UpdateSubscription/029_04.robot'
        expected_value = f'{self.folder_test_suites}/doc/files/ContextInformation/Subscription/029_04.json'
        difference_file = f'{self.folder_test_suites}/doc/results/out_029_04.json'

        self.common_function(robot_file=robot_file, expected_value=expected_value, difference_file=difference_file)

    def test_029_05(self):
        robot_file = f'{self.folder_test_suites}/TP/NGSI-LD/ContextInformation/Subscription/UpdateSubscription/029_05.robot'
        expected_value = f'{self.folder_test_suites}/doc/files/ContextInformation/Subscription/029_05.json'
        difference_file = f'{self.folder_test_suites}/doc/results/out_029_05.json'

        self.common_function(robot_file=robot_file, expected_value=expected_value, difference_file=difference_file)

    def test_029_06(self):
        robot_file = f'{self.folder_test_suites}/TP/NGSI-LD/ContextInformation/Subscription/UpdateSubscription/029_06.robot'
        expected_value = f'{self.folder_test_suites}/doc/files/ContextInformation/Subscription/029_06.json'
        difference_file = f'{self.folder_test_suites}/doc/results/out_029_06.json'

        self.common_function(robot_file=robot_file, expected_value=expected_value, difference_file=difference_file)

        print("WARNING, (029_06) there is a important miss alignment with the documentation")

    def test_029_07(self):
        self.fail("(029_07) Test Suite with Test Template, not yet implemented")

    def test_029_08(self):
        self.fail("(029_08) Test Suite with Test Template, not yet implemented")

    def test_029_09(self):
        robot_file = f'{self.folder_test_suites}/TP/NGSI-LD/ContextInformation/Subscription/UpdateSubscription/029_09.robot'
        expected_value = f'{self.folder_test_suites}/doc/files/ContextInformation/Subscription/029_09.json'
        difference_file = f'{self.folder_test_suites}/doc/results/out_029_09.json'

        self.common_function(robot_file=robot_file, expected_value=expected_value, difference_file=difference_file)

        print("WARNING, (029_09) there is a important miss alignment with the documentation")

    def test_029_10(self):
        robot_file = f'{self.folder_test_suites}/TP/NGSI-LD/ContextInformation/Subscription/UpdateSubscription/029_10.robot'
        expected_value = f'{self.folder_test_suites}/doc/files/ContextInformation/Subscription/029_10.json'
        difference_file = f'{self.folder_test_suites}/doc/results/out_029_10.json'

        self.common_function(robot_file=robot_file, expected_value=expected_value, difference_file=difference_file)

        print("WARNING, (029_10) there is a important miss alignment with the documentation")

    def test_029_11(self):
        robot_file = f'{self.folder_test_suites}/TP/NGSI-LD/ContextInformation/Subscription/UpdateSubscription/029_11.robot'
        expected_value = f'{self.folder_test_suites}/doc/files/ContextInformation/Subscription/029_11.json'
        difference_file = f'{self.folder_test_suites}/doc/results/out_029_11.json'

        self.common_function(robot_file=robot_file, expected_value=expected_value, difference_file=difference_file)
