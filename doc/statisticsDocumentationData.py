from generateDocumentationData import create_json_of_robotfile
from os.path import dirname
from os import walk
from json import dump

if __name__ == "__main__":
    basedir = dirname(dirname(__file__))
    statistics = dict()
    testcases = []
    number_of_failures = 0
    number_of_all_testcases = 0
    number_of_successes = 0
    ROBOT_FILE_EXTENSION = ".robot"

    fullpath = basedir+"/TP/NGSI-LD"
    for root, dirs, files in walk(fullpath):
        for filename in files:
            if filename.endswith(ROBOT_FILE_EXTENSION):
                number_of_all_testcases += 1
                name_of_test_case = filename[:-len(ROBOT_FILE_EXTENSION)]
                json_of_test_case = create_json_of_robotfile(name_of_test_case, True)
                statistics[name_of_test_case] = dict()
                strippedpath = root[len(fullpath)+1:]
                statistics[name_of_test_case]["path"] = strippedpath
                if "error_while_parsing" in json_of_test_case and json_of_test_case["error_while_parsing"]:
                    statistics[name_of_test_case]["failed"] = True
                    number_of_failures += 1
                else:
                    statistics[name_of_test_case]["failed"] = False
                    number_of_successes += 1
                    testcases.append(json_of_test_case)

    print()
    print()
    print()
    print("THE FOLLOWING TESTCASES FAILED PARSING:")
    for testcasename, testcaseresult in statistics.items():
        if testcaseresult["failed"]:
            print(testcasename+" "+testcaseresult["path"])
    
    print(f"Out of {number_of_all_testcases} testcases, {number_of_failures} of them failed to be correctly parsed.")

    with open("./results/testcases.json", 'w') as fp:
        dump(obj=testcases, indent=2, fp=fp)
