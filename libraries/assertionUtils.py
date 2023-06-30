from dataclasses import dataclass
from deepdiff import DeepDiff
from prettydiff import get_annotated_lines_from_diff, diff_json, Flag
from robot.api import logger


@dataclass
class Theme:
    added: str
    removed: str
    reset: str


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

    if len(res) > 0:
        output_pretty_diff(expected, actual, Theme(added="", removed="", reset=""))
    return res


def output_pretty_diff(a, b, theme, indent_size: int = 2, console=False):
    logger.info("Dictionary comparison failed with -> ", also_console=True)
    lines = get_annotated_lines_from_diff(diff_json(a, b))

    msg = ""
    for line in lines:
        if Flag.ADDED in line.flags:
            flags = f"{theme.added}+ "
        elif Flag.REMOVED in line.flags:
            flags = f"{theme.removed}- "
        else:
            flags = f"{theme.reset} "

        msg = msg + flags + " " * (indent_size * line.indent) + line.s + "\n"

    logger.info(msg, also_console=True)
