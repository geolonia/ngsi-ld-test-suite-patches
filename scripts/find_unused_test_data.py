import os


def list_files_in_dir(dirname):
    for fname in os.listdir(dirname):
        if os.path.isfile(dirname + "/" + fname):
            print("Looking at test data file: ", fname)
            find_test_data_in_tc("TP", fname)
        else:
            list_files_in_dir(dirname + "/" + fname)


def find_test_data_in_tc(dir, filename):
    for file in os.listdir(dir):
        path = dir + "/" + file
        if os.path.isdir(path):
            find_test_data_in_tc(path, filename)
        else:
            if filename in open(path).read():
                print("Found usage of", filename, "in", path)


list_files_in_dir("data")
