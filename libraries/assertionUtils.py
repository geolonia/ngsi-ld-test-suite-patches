import re
from dataclasses import dataclass
from deepdiff import DeepDiff
from deepdiff.helper import CannotCompare
from prettydiff import get_annotated_lines_from_diff, diff_json, Flag
from robot.api import logger


@dataclass
class Theme:
    added: str
    removed: str
    reset: str


def wrap_context_to_list(context):
    if type(context) is str:
        return [context]
    else:
        return context


core_context_pattern = re.compile('https://uri.etsi.org/ngsi-ld/v1/ngsi-ld-core-context-v\d\.\d.jsonld')


class AnyCoreContextVersionOperator:
    def match(self, level) -> bool:
        return level.path().endswith("['@context']")

    def give_up_diffing(self, level, diff_instance) -> bool:
        actual_context = wrap_context_to_list(level.t2)
        return len(actual_context) == 1 and core_context_pattern.match(actual_context[0]) is not None


class StringOrSingleListContextOperator:

    def match(self, level) -> bool:
        # The context can be at the root of the element to check... or deeper when we have list of elements
        # So match on the end of the path
        return level.path().endswith("['@context']")

    def give_up_diffing(self, level, diff_instance) -> bool:
        expected_context = wrap_context_to_list(level.t1)
        actual_context = wrap_context_to_list(level.t2)
        return expected_context == actual_context


def compare_func(x, y, level=None):
    try:
        return x['id'] == y['id']
    except Exception:
        raise CannotCompare() from None


def compare_dictionaries_ignoring_keys(expected, actual, exclude_regex_paths, ignore_core_context_version=False,
                                       group_by=None):
    """Function exposed as a keyword to compare two dictionaries
    :param expected: expected dictionary
    :param actual: actual dictionary
    :param exclude_regex_paths: list of regex paths of keys to be ignored
    :param ignore_core_context_version: whether any core context version is allowed in the results
    :param group_by: a key to group the results, useful for lists of results
    """

    if group_by is not None and ignore_core_context_version:
        res = DeepDiff(expected, actual, exclude_regex_paths=exclude_regex_paths, ignore_order=True, verbose_level=1,
                       iterable_compare_func=compare_func, custom_operators=[AnyCoreContextVersionOperator()],
                       group_by=group_by)
    elif group_by is not None:
        res = DeepDiff(expected, actual, exclude_regex_paths=exclude_regex_paths, ignore_order=True, verbose_level=1,
                       iterable_compare_func=compare_func, custom_operators=[StringOrSingleListContextOperator()],
                       group_by=group_by)
    elif ignore_core_context_version:
        res = DeepDiff(expected, actual, exclude_regex_paths=exclude_regex_paths, ignore_order=True, verbose_level=1,
                       iterable_compare_func=compare_func, custom_operators=[AnyCoreContextVersionOperator()])
    else:
        res = DeepDiff(expected, actual, exclude_regex_paths=exclude_regex_paths, ignore_order=True, verbose_level=1,
                       iterable_compare_func=compare_func, custom_operators=[StringOrSingleListContextOperator()])

    if len(res) > 0:
        output_pretty_diff(expected, actual, Theme(added="", removed="", reset=""))
    return res


def output_pretty_diff(a, b, theme, indent_size: int = 2):
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
