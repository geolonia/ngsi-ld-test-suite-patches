from analysis.generaterobotdata import GenerateRobotData
from json import dump
from sys import argv
from os.path import dirname, exists
from os import makedirs, walk


def create_json_of_robotfile(
    robot_file_to_be_processed: str,
    computestatistics: bool = False,
    robot_file: str = None,
):
    # TODO: ApiUtils.resource -> 'Delete Context Source Registration Subscription' added 'url=' as parameter
    folder_test_suites = dirname(dirname(__file__)).replace("\\", "/")
    folder_result_path = f"{folder_test_suites}/doc/results"
    result_file = f"{folder_result_path}/{robot_file_to_be_processed}.json"

    if robot_file is None:
        robot_path_to_be_processed, robot_file = find_robot_file(
            basedir=folder_test_suites, filename=robot_file_to_be_processed
        )
    else:
        robot_file = robot_file.replace("\\", "/")
        robot_path_to_be_processed = strip_tp_folder(
            basedir=folder_test_suites, path=dirname(robot_file)
        )

    if robot_path_to_be_processed is None and robot_file is None:
        print(f"No robot file found with name: {robot_file_to_be_processed}")
        exit(1)

    # Check that the folder '/results' exists and if not, create it
    if not exists(folder_result_path):
        makedirs(folder_result_path)

    if computestatistics:
        try:
            data = GenerateRobotData(robot_file=robot_file, execdir=folder_test_suites)
            data.parse_robot()
            info = data.get_info()
            info["error_while_autogenerating"] = "no error"
        except Exception as e:
            print("WHILE GENERATING ROBOT DATA:", e)
            info = dict()
            info["error_while_parsing"] = True
            info["error_while_autogenerating"] = str(e)
            info["robotfile"] = robot_file_to_be_processed
            if robot_path_to_be_processed.startswith("/"):
                robot_path_to_be_processed = robot_path_to_be_processed[1:]
            info["robotpath"] = robot_path_to_be_processed
    else:
        data = GenerateRobotData(robot_file=robot_file, execdir=folder_test_suites)
        data.parse_robot()
        info = data.get_info()

    with open(result_file, "w") as fp:
        dump(obj=info, indent=2, fp=fp)

    return info


def tp_folders(basedir: str):
    return (f"{basedir}/TP/NGSI-LD", f"{basedir}/IOP_TP/NGSI-LD")


def strip_tp_folder(basedir: str, path: str):
    """Return 'path' relative to whichever TP root contains it, e.g. '/DistributedOperations/LoopDetection'."""
    for tp_folder in tp_folders(basedir):
        if path.startswith(tp_folder):
            return path[len(tp_folder) :]
    return path


def find_robot_file(basedir: str, filename: str):
    filename = f"{filename}.robot"
    for tp_folder in tp_folders(basedir):
        for root, _, files in walk(tp_folder):
            root = root.replace("\\", "/")
            if filename in files:
                return strip_tp_folder(basedir, root), f"{root}/{filename}"
    return None, None


if __name__ == "__main__":
    # Call with the folder below /TP/NGSI-LD or /IOP_TP/NGSI-LD which contains the robot file with name args[0]
    args = argv[1:]
    if len(args) == 0:
        basedir = dirname(dirname(__file__)).replace("\\", "/")

        # Process all TP and IOP files
        for tp_path in tp_folders(basedir):
            if not exists(tp_path):
                continue
            for root, _, files in walk(tp_path):
                root = root.replace("\\", "/")
                for file in files:
                    if file.endswith(".robot"):
                        filename = file.replace(".robot", "")
                        print(f"Generating json for {filename}")
                        create_json_of_robotfile(
                            filename,
                            computestatistics=True,
                            robot_file=f"{root}/{file}",
                        )
    else:
        robot_file_tbp = args[0]
        resulting_json = create_json_of_robotfile(robot_file_tbp)

    print("\nCorrectly exiting")
