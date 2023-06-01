from deepdiff import DeepDiff


def compare_dictionaries_ignoring_keys(expected, actual, exclude_regex_paths, group_by=None):
    """Function exposed as a keyword to compare two dictionaries
    :param expected: expected dictionary
    :param actual: actual dictionary
    :param exclude_regex_paths: list of regex paths of keys to be ignored
    :param group_by: a key to group the results, useful for lists of results
    """

    if group_by is not None:
        res = DeepDiff(expected, actual, exclude_regex_paths=exclude_regex_paths, ignore_order=True, verbose_level=1,
                       group_by=group_by)
    else:
        res = DeepDiff(expected, actual, exclude_regex_paths=exclude_regex_paths, ignore_order=True, verbose_level=1)
    return res
