from pprint import pprint
from doc.analysis.generaterobotdata import GenerateRobotData

if __name__ == "__main__":
    data = GenerateRobotData(robot_file='../TP/NGSI-LD/CommonBehaviours/043.robot',
                             execdir='/home/fla/Documents/workspace/bdd/ngsi-ld-test-suite')
    data.parse_robot()
    info = data.get_info()
    pprint(info)

    data = GenerateRobotData(robot_file='../TP/NGSI-LD/ContextInformation/Provision/Entities/CreateEntity/001_01.robot',
                             execdir='/home/fla/Documents/workspace/bdd/ngsi-ld-test-suite')
    data.parse_robot()
    info = data.get_info()
    pprint(info)
