from deepdiff import DeepDiff

def compare_dictionaries_ignoring_keys(dict1, dict2, exclude_regex_paths):
    """Function exposed as a keyword to compare two dictionaries
    :param dict1: actual dictionary
    :param dict2: expected dictionary
    :param exclude_regex_paths: regex path of keys to be ignored
    """
    res = DeepDiff(dict1, dict2, exclude_regex_paths=[exclude_regex_paths], ignore_order=True)
    print(res)
    return not res
