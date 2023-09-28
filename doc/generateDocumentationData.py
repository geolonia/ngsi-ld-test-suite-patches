from doc.analysis.generaterobotdata import GenerateRobotData
import json
import sys
from os.path import dirname, exists
from os import makedirs

def create_json_of_robotfile(robot_path_to_be_processed: str, robot_file_to_be_processed: str):
    folder_test_suites = dirname(dirname(__file__))
    folder_result_path = f'{folder_test_suites}/doc/results'
    result_file = f'{folder_result_path}/{robot_file_to_be_processed}.json'
    robot_file = f'{folder_test_suites}/TP/NGSI-LD/{robot_path_to_be_processed}/{robot_file_to_be_processed}.robot'

    # Check that the folder '/results' exists and if not, create it
    if not exists(folder_result_path):
        makedirs(folder_result_path)

    try:
        data = GenerateRobotData(robot_file=robot_file, execdir=folder_test_suites)
        data.parse_robot()
        info = data.get_info()
    except Exception as e:
        print("WHILE GENERATING ROBOT DATA:", e)
        info = {}
        info["error_while_parsing"] = True

    info["robotpath"] = robot_path_to_be_processed
    info["robotfile"] = robot_file_to_be_processed

    with open(result_file, 'w') as fp:
        json.dump(obj=info, indent=4, fp=fp)

    return info

if __name__ == "__main__":
    args = sys.argv[1:]
    robot_path_tbp = args[0]
    robot_file_tbp = args[1]
    resulting_json = create_json_of_robotfile(robot_path_tbp, robot_file_tbp)
    print("Correctly exiting")
