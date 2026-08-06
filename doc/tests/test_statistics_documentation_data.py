import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "doc"))

from statisticsDocumentationData import replace_test_step_filename_variables


class TestStepFilenameVariablesTest(unittest.TestCase):
    def test_replaces_variables_with_filenames(self):
        robot = """*** Variables ***
${entity_payload_filename}    interoperability/full-version.jsonld


*** Test Cases ***
Example
    No Operation
"""
        testcase = {
            "test_cases": [
                {
                    "test_steps": [
                        "Create ${entity_payload_filename}",
                        [
                            "Use ${entity_payload_filename}",
                            "Keep ${runtime_variable}",
                        ],
                    ]
                }
            ]
        }

        with tempfile.TemporaryDirectory() as temporary_directory:
            robot_file = Path(temporary_directory) / "example.robot"
            robot_file.write_text(robot, encoding="utf-8")
            replace_test_step_filename_variables(
                testcase=testcase,
                robot_file=str(robot_file),
            )

        self.assertEqual(
            testcase["test_cases"][0]["test_steps"],
            [
                "Create full-version.jsonld",
                [
                    "Use full-version.jsonld",
                    "Keep ${runtime_variable}",
                ],
            ],
        )


if __name__ == "__main__":
    unittest.main()
