from pprint import pprint
from doc.analysis.generaterobotdata import GenerateRobotData
import json
from os.path import dirname, exists
from os import makedirs

if __name__ == "__main__":
    folder_test_suites = dirname(dirname(__file__))
    folder_result_path = f'{folder_test_suites}/doc/results'
    result_file = f'{folder_result_path}/result.json'
    robot_file = f'{folder_test_suites}/TP/NGSI-LD/CommonBehaviours/044_01.robot'

    # Check that the folder '/results' exists and if not, create it
    if not exists(folder_result_path):
        makedirs(folder_result_path)

    data = GenerateRobotData(robot_file=robot_file,
                             execdir=folder_test_suites)
    data.parse_robot()
    info = data.get_info()

    with open(result_file, 'w') as fp:
        json.dump(obj=info, indent=4, fp=fp)

    # data = GenerateRobotData(robot_file='../TP/NGSI-LD/ContextInformation/Provision/Entities/CreateEntity/001_01.robot',
    #                          execdir='/home/fla/Documents/workspace/bdd/ngsi-ld-test-suite')
    # data.parse_robot()
    # info = data.get_info()
    # pprint(info)
