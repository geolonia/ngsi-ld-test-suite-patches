import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'doc'))

from analysis.generaterobotdata import GenerateRobotData


class IopPreconditionsTest(unittest.TestCase):
    def generate(self, variables: str, setup: str, test_body: str = '    No Operation'):
        robot = f'''*** Settings ***
Documentation       Objective
Test Setup          Prepare Preconditions


*** Variables ***
{variables}


*** Test Cases ***
IOP_999_01 Generated Preconditions
    [Documentation]    Pre-conditions: documentation must be ignored.
    [Tags]
    ...    since_v1.6.1
    ...    iop
    ...    4_3_3
{test_body}


*** Keywords ***
Prepare Preconditions
{setup}
'''
        self.generate_from_robot(robot)
        return self.generated_info['initial_conditions']

    def generate_from_robot(self, robot: str):
        temporary_directory = tempfile.TemporaryDirectory()
        self.addCleanup(temporary_directory.cleanup)
        path = (
            Path(temporary_directory.name)
            / 'IOP_TP'
            / 'NGSI-LD'
            / 'Interoperability'
            / 'Consumption'
            / 'Entity'
            / 'QueryEntities'
            / 'IOP_999_01.robot'
        )
        path.parent.mkdir(parents=True)
        path.write_text(robot, encoding='utf-8')

        generator = GenerateRobotData(robot_file=str(path), execdir=str(ROOT))
        generator.parse_robot()
        self.generated_info = generator.get_info()
        return self.generated_info

    def test_removes_tag_continuation_markers(self):
        self.generate(
            variables='${b1_url}    ${EMPTY}',
            setup='    No Operation'
        )

        self.assertEqual(
            self.generated_info['test_cases'][0]['tags'],
            ['since_v1.6.1', 'iop', '4_3_3']
        )

    def test_generates_mixed_context_and_data_objects(self):
        result = self.generate(
            variables='''${first_payload}     fixtures/first-entity.jsonld
${context_path}      https://example.test/contexts/example-context.jsonld?version=1
${broker_alias}      ${b2_url}
${b2_url}            ${EMPTY}
${b3_url}            ${EMPTY}''',
            setup='''    ${response}=    Create Entity
    ...    ${first_payload}
    ...    urn:ngsi-ld:Example:1
    ...    broker_url=${broker_alias}
    ...    context=${context_path}
    Create Entity
    ...    second-entity.json
    ...    urn:ngsi-ld:Example:2
    ...    ${EMPTY}
    ...    ${b3_url}
    ...    ${ngsild_test_suite_context}''',
            test_body='''    Create Entity
    ...    ignored-body-entity.jsonld
    ...    urn:ngsi-ld:Example:3
    ...    broker_url=${b3_url}'''
        )

        self.assertEqual(
            result['pre_conditions'],
            [
                {
                    'type': 'context',
                    'top-level': 'The following user contexts are used:',
                    'nested-object': [
                        (
                            'User context when creating the entity with id '
                            'urn:ngsi-ld:Example:1 in broker b2.'
                        ),
                        (
                            'User context when creating the entity with id '
                            'urn:ngsi-ld:Example:2 in broker b3.'
                        )
                    ]
                },
                {
                    'type': 'data',
                    'top-level': 'Data in following brokers:',
                    'nested-object': [
                        'b2 contains first-entity.jsonld.',
                        'b3 contains second-entity.json.'
                    ]
                }
            ]
        )

    def test_uses_test_suite_context_when_context_is_omitted(self):
        result = self.generate(
            variables='${b2_url}    ${EMPTY}',
            setup=(
                '    Create Entity    repeated.jsonld    urn:ngsi-ld:Example:1'
                '    broker_url=${b2_url}\n'
                '    Create Entity    repeated.jsonld    urn:ngsi-ld:Example:2'
                '    broker_url=${b2_url}'
            )
        )

        self.assertEqual(
            result['pre_conditions'],
            [
                {
                    'type': 'context',
                    'top-level': 'User context used in every operation.',
                    'nested-object': []
                },
                {
                    'type': 'data',
                    'top-level': 'Data in following brokers:',
                    'nested-object': [
                        'b2 contains repeated.jsonld.',
                        'b2 contains repeated.jsonld.'
                    ]
                }
            ]
        )

    def test_uses_no_user_context_when_all_operations_use_core_context(self):
        result = self.generate(
            variables='${b1_url}    ${EMPTY}',
            setup='''    Set Test Variable    ${entity_id}    urn:ngsi-ld:Example:1
    Create Entity    entity.jsonld    ${entity_id}    broker_url=${b1_url}    context=${core_context}
    @{configuration}=    Create List
    Compose IOP Configuration    ${configuration}    ld_context=${core_context}'''
        )

        self.assertEqual(
            result['pre_conditions'][0],
            {
                'type': 'context',
                'top-level': 'No user context used.',
                'nested-object': []
            }
        )

    def test_generates_conditions_for_parameterized_setup_permutations(self):
        self.generate_from_robot('''*** Settings ***
Documentation       Objective
Test Template       Run Scenario


*** Variables ***
${b1_url}    ${EMPTY}


*** Test Cases ***
IOP_999_01_01 Default Context
    [Tags]    since_v1.6.1    iop    4_3_3    default-context
    [Setup]    Prepare Preconditions    ${core_context}
    ${core_context}

IOP_999_01_02 User Context
    [Tags]    since_v1.6.1    iop    4_3_3    user-context
    [Setup]    Prepare Preconditions    context=${ngsild_test_suite_context}
    ${ngsild_test_suite_context}


*** Keywords ***
Run Scenario
    [Documentation]    Run context permutation
    [Arguments]    ${context}
    # Shared template action
    # - Shared template detail
    No Operation

Prepare Preconditions
    [Arguments]    ${context}
    @{configuration}=    Create List
    Compose IOP Configuration    ${configuration}    ld_context=${context}
''')

        default_conditions = self.generated_info['test_cases'][0]['initial_conditions']
        user_conditions = self.generated_info['test_cases'][1]['initial_conditions']

        self.assertNotIn('initial_conditions', self.generated_info)
        self.assertEqual(
            default_conditions['pre_conditions'][0],
            {
                'type': 'context',
                'top-level': 'No user context used.',
                'nested-object': []
            }
        )
        self.assertEqual(
            user_conditions['pre_conditions'][0],
            {
                'type': 'context',
                'top-level': 'User context used in every operation.',
                'nested-object': []
            }
        )
        self.assertIn('default-context', self.generated_info['test_cases'][0]['tags'])
        self.assertIn('user-context', self.generated_info['test_cases'][1]['tags'])
        self.assertEqual(
            self.generated_info['test_cases'][0]['test_steps'],
            ['Shared template action', ['Shared template detail']]
        )
        self.assertEqual(
            self.generated_info['test_cases'][1]['test_steps'],
            self.generated_info['test_cases'][0]['test_steps']
        )

    def test_generates_mixed_entity_and_registration_contexts(self):
        result = self.generate(
            variables='${b1_url}    ${EMPTY}',
            setup='''    Set Test Variable    ${entity_id}    urn:ngsi-ld:Example:1
    Create Entity    entity.jsonld    ${entity_id}    broker_url=${b1_url}    context=${core_context}
    @{configuration}=    Create List
    Compose IOP Configuration    ${configuration}    ld_context=${ngsild_test_suite_context}'''
        )

        self.assertEqual(
            result['pre_conditions'][0],
            {
                'type': 'context',
                'top-level': 'The following user contexts are used:',
                'nested-object': [
                    (
                        'Default context when creating the entity with id '
                        'urn:ngsi-ld:Example:1 in broker b1.'
                    ),
                    'User context when creating the registrations in all brokers.'
                ]
            }
        )

    def test_uses_empty_objects_without_create_entity(self):
        result = self.generate(
            variables='${b1_url}    ${EMPTY}',
            setup='    No Operation'
        )

        self.assertEqual(
            result['pre_conditions'],
            [
                {
                    'type': 'context',
                    'top-level': 'No user context used.',
                    'nested-object': []
                },
                {
                    'type': 'data',
                    'top-level': 'No data in any broker.',
                    'nested-object': []
                }
            ]
        )
        self.assertEqual(result['registrations_established'], [])

    def test_generates_sorted_registration_array(self):
        result = self.generate(
            variables='''${b1_url}     ${EMPTY}
${b2_url}     ${EMPTY}
${b3_url}     ${EMPTY}
${b5_url}     ${EMPTY}
${b10_url}    ${EMPTY}''',
            setup='''    @{redirect}=    Create List
    ...    ${EMPTY}
    ...    redirect.jsonld
    ...    redirect
    ...    ${b5_url}
    ...    ${b1_url}
    @{last}=    Create List
    ...    ${EMPTY}
    ...    exclusive.jsonld
    ...    exclusive
    ...    ${b1_url}
    ...    ${b10_url}
    @{duplicate}=    Create List
    ...    urn:ngsi-ld:Example:1
    ...    exclusive-other.jsonld
    ...    exclusive
    ...    ${b1_url}
    ...    ${b10_url}
    @{inclusive}=    Create List
    ...    ${EMPTY}
    ...    inclusive.jsonld
    ...    inclusive
    ...    ${b2_url}
    ...    ${b1_url}
    @{auxiliary}=    Create List
    ...    ${EMPTY}
    ...    auxiliary.jsonld
    ...    auxiliary
    ...    ${b3_url}
    ...    ${b2_url}'''
        )

        self.assertEqual(
            result['registrations_established'],
            [
                'Inclusive b1 to b2 (Figure inclusive.jsonld).',
                'Redirect b1 to b5 (Figure redirect.jsonld).',
                'Auxiliary b2 to b3 (Figure auxiliary.jsonld).',
                'Exclusive b10 to b1 (Figure exclusive.jsonld).',
                'Exclusive b10 to b1 (Figure exclusive-other.jsonld).'
            ]
        )

    def test_rejects_invalid_broker(self):
        with self.assertRaisesRegex(
            ValueError,
            r"Create Entity broker variable '\$\{broker_url\}' is invalid"
        ):
            self.generate(
                variables='${broker_url}    https://example.test',
                setup=(
                    '    Create Entity    entity.jsonld    urn:ngsi-ld:Example:1'
                    '    broker_url=${broker_url}'
                )
            )

    def test_rejects_undefined_payload_and_context_variables(self):
        with self.assertRaisesRegex(
            ValueError,
            r"Create Entity payload variable '\$\{missing_payload\}' is not defined"
        ):
            self.generate(
                variables='${b1_url}    ${EMPTY}',
                setup=(
                    '    Create Entity    ${missing_payload}    urn:ngsi-ld:Example:1'
                    '    broker_url=${b1_url}'
                )
            )

        with self.assertRaisesRegex(
            ValueError,
            r"Create Entity context variable '\$\{missing_context\}' is not defined"
        ):
            self.generate(
                variables='${b1_url}    ${EMPTY}',
                setup=(
                    '    Create Entity    entity.jsonld    urn:ngsi-ld:Example:1'
                    '    broker_url=${b1_url}    context=${missing_context}'
                )
            )


if __name__ == '__main__':
    unittest.main()
