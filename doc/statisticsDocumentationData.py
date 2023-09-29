from generateDocumentationData import create_json_of_robotfile
from os.path import dirname
from os import walk

if __name__ == "__main__":
    basedir = dirname(dirname(__file__))
    statistics = dict()
    number_of_failures = 0
    number_of_testcases = 0

    fullpath = basedir+"/TP/NGSI-LD"
    for root, dirs, files in walk(fullpath):
        for filename in files:
            if filename.endswith(".robot"):
                number_of_testcases += 1
                name_of_test_case = filename[:-6]
                json_of_test_case = create_json_of_robotfile(name_of_test_case, True)
                statistics[name_of_test_case] = dict()
                strippedpath = root[len(fullpath)+1:]
                statistics[name_of_test_case]["path"] = strippedpath
                if "error_while_parsing" in json_of_test_case and json_of_test_case["error_while_parsing"] == True:
                    statistics[name_of_test_case]["failed"] = True
                    number_of_failures += 1
                else:
                    statistics[name_of_test_case]["failed"] = False

    print()
    print()
    print()
    print("THE FOLLOWING TESTCASES FAILED PARSING:")
    for testcasename, testcaseresult in statistics.items():
        if testcaseresult["failed"] == True:
            print(testcasename+" "+testcaseresult["path"])
    
    print("Out of "+str(number_of_testcases)+" testcases, "+str(number_of_failures)+" of them failed to be correctly parsed")