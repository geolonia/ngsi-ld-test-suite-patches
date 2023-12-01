import os
import robot


def find_test_data_in_tc(dir, filename, run_matching_tc):
    for file in os.listdir(dir):
        path = dir + "/" + file
        if os.path.isdir(path):
            find_test_data_in_tc(path, filename, run_matching_tc)
        else:
            if filename in open(path).read():
                if run_matching_tc == "Y":
                    robot.run(path)
                print(path)


if __name__ == '__main__':
    test_data_file = input("Name of test data file to search for: ")
    run_matching_tc = input("Run matching Test Cases (Y/N)?: ")
    find_test_data_in_tc("TP", test_data_file, run_matching_tc)
