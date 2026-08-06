# Automatic generation of documentation data (ETSI RGS CIM 013)

This Python code has been developed to facilitate the automatic generation of the test purposes descriptions in a JSON 
format to automatically generate afterward the NGSI-LD Test Purposes Descriptions (ETSI RGS CIM 013) document.
To achieve this purpose, we are defining a full Unit Test Suite with several Test Cases to check that we can generate
the corresponding information of the Robot description files. 

This approach has a clear advantage, from one side, we can generate the corresponding info for the ETSI document and
for the other side, it can help us to know when a change in the Robot Description files was developed and therefore
an update in the ETSI document (new version of the document) must be generated.

## Requirements

This Python code is developed under the scope of the overall NGSI-LD Test Suite Code, therefore we use the same
requirements and python virtual environment already defined in [README.md](../README.md).

## Structure

The unit tests are divided into several groups following the NGSI-LD Test Suite Structure (ETSI RGS CIM 012) divided
in test groups and subgroups:

- Group 1: Context Information (CI), Provision (PROV), defined in the 
[test_ContextInformation_Provision.py](./tests/test_ContextInformation_Provision.py) file.
- Group 2: Context Information (CI), Consumption (CONS), defined in the 
[test_ContextInformation_Consumption.py](./tests/test_ContextInformation_Consumption.py) file.
- Group 3: Context Information (CI), Subscription (SUB), defined in the 
[test_ContextInformation_Subscription.py](./tests/test_ContextInformation_Subscription.py) file.
- Group 4: Context Source (CS), Registration (REG), defined in the 
[test_ContextSource_Registration.py](./tests/test_ContextSource_Registration.py) file.
- Group 5: Context Source (CS), Discovery (DISC), defined in the 
[test_ContextSource_Discovery.py](./tests/test_ContextSource_Discovery.py) file.
- Group 6: Context Source (CS), Registration Subscription (REGSUB), defined in the 
[test_ContextSource_RegistrationSubscription.py](./tests/test_ContextSource_RegistrationSubscription.py) file.
- Group 7: Common Behaviours (CB), defined in the 
[test_CommonBehaviours.py](./tests/test_CommonBehaviours.py) file.
- Group 8: Storing, Managing and Serving @contexts (CTX), Consumption (CONS), defined in the 
[test_jsonldContext_Consumption.py](./tests/test_jsonldContext_Consumption.py) file.
- Group 9: Storing, Managing and Serving @contexts (CTX), Provision (PROV), defined in the 
[test_jsonldContext_Provision.py](./tests/test_jsonldContext_Provision.py) file.

Additionally, a specific unit test called [test_CheckTests.py](./tests/test_CheckTests.py) was created to check that all
robot files have the corresponding unit tests. 

Moreover, the [files](./files) folder contains the expected results of the execution of the Unit Tests, and they are 
divided into the NGSI-LD Test Suite Structure groups:

- [CommonBehaviours](./files/CommonBehaviours) contains the expected results of the Common Behaviours robot files.
- [ContextInformation](./files/ContextInformation) contains the expected results of the Context Information files.
- [ContextSource](./files/ContextSource) contains the expected results of the Context Source files.
- [jsonldContext](./files/jsonldContext) contains the expected results of the Storing, Managing and Serving @contexts files.

## Rules for writing tests

When writing interoperability tests, store each payload as a valid UTF-8 JSON object with a unique, descriptive, hyphen-separated `.json` or `.jsonld` filename in either [`data/entities/interoperability`](../data/entities/interoperability) or [`data/csourceRegistrations/interoperability`](../data/csourceRegistrations/interoperability). Entity payloads must contain a `type` value of exactly `OffStreetParking` or `Vehicle`, while context source registration payloads must contain a `mode` value of exactly `inclusive`, `auxiliary`, `exclusive`, or `redirect`; these values determine the documentation clause, and the filename determines the generated figure label. When introducing another type, mode, or clause, update the mappings in [`statisticsDocumentationData.py`](./statisticsDocumentationData.py).

State the test objective with the suite-level `Documentation` setting in the `*** Settings ***` section. Use `...` continuation lines when the objective spans multiple lines. For interoperability tests, a test-level `[Documentation]` setting is not used to populate `test_objective`.

The documentation generator infers preconditions from the keyword selected by `Test Setup`, including test-specific setup overrides and their positional or named arguments. Place the relevant `Create Entity` and `Create List` calls directly in that setup keyword; calls made only in the test body or indirectly through another user keyword are not considered. A `Create Entity` call must provide the payload filename and a broker variable resolving to `${bN_url}` through the `broker_url` argument. It generates text stating that broker `bN` contains that payload. `${core_context}` is classified as the default context, while `${ngsild_test_suite_context}` and other context values are classified as user contexts. A registration is inferred only from a `Create List` call having exactly five arguments in the following order: entity information, registration payload, registration mode, target broker URL, and registering broker URL. Its mode must be one of `inclusive`, `auxiliary`, `exclusive`, or `redirect`, and its broker variables must use the `${bN_url}` form. Every generated IOP permutation contains its own `initial_conditions`; suite-level `initial_conditions` is emitted only for files containing one test case.

Add `[Tags]` to every test case. Use an `iop` tag for interoperability tests, one `cnf_NN` tag identifying the applicable configuration, numeric clause tags written with underscores such as `4_3_3`, and a `since_vX.Y.Z` tag identifying the first supported release. The numeric tags are converted to specification clause numbers, and all test cases in one file must use the same release tag. Add `default-context` or `user-context` to context permutations and registration-behaviour tags such as `additive-inclusive`, `additive-auxiliary`, `proxy-exclusive`, or `proxy-redirect` when applicable. Tags may continue on lines beginning with `...`; the continuation marker is discarded.

Write every documentation step as a standalone line comment immediately before the Robot Framework statement it describes. A comment such as `# Client sends an HTTP GET request to b1` becomes one generated test step. For IOP test templates, place shared steps in the template keyword; the generator uses them when a permutation has no inline comments. Inline test-case comments override template comments. To add details beneath a step, place consecutive comments beginning with `# -` after a normal parent comment. Do not use a `# -` item without a preceding parent step, and do not rely on setup or trailing comments.

When a documentation step refers to a payload that is created, returned, or compared, include the Robot Framework variable containing its path instead of writing the payload description or figure number manually. The variable must be declared in the `*** Variables ***` section and resolve to the relevant payload file. For example:

```robotframework
*** Variables ***
${entity_payload_filename}    interoperability/full-version-of-OffStreetParking1.jsonld

*** Test Cases ***
IOP_001_01_01 Create OffStreetParking:1
    # Client sends an HTTP POST request to b1 to create the entity defined in ${entity_payload_filename}
    ${response}=    Create Entity    ${entity_payload_filename}    ${entity_id}    broker_url=${b1_url}
```

During statistics generation, `${entity_payload_filename}` in the generated step is replaced with `full-version-of-OffStreetParking1.jsonld`. Only the filename is emitted; the directory path is removed. Do not include explicit figure numbers because the documentation generator infers the corresponding figure from the filename.

## Execution

### Using PyCharm

You have several options to execute the tests. It was generated a set of PyCharm configuration files in the 
[runConfigurations](../.idea/runConfigurations) folder to help in the execution of the unit tests from the IDE:

- [All Unit Tests](../.idea/runConfigurations/All_Unit_Tests.xml) executes all Unit Tests associated to the robot files.
- [CheckTests Unit Tests](../.idea/runConfigurations/CheckTests_Unit_Tests.xml) checks that there is a unit test associated to each robot file.
- [CommonBehaviours Unit Tests](../.idea/runConfigurations/CommonBehaviours_Unit_Tests.xml) executes Common Behaviours unit tests associated to the robot files.
- [ContextInformation Consumption Unit Tests](../.idea/runConfigurations/ContextInformation_Consumption_Unit_Tests.xml) executes Context Information - Consumption unit tests associated to 
the robot files.
- [ContextInformation Provision Unit Tests](../.idea/runConfigurations/ContextInformation_Provision_Unit_Tests.xml) executes Context Information - Provision unit tests associated to the 
robot files.
- [ContextInformation Subscription Unit Tests](../.idea/runConfigurations/ContextInformation_Subscription_Unit_Tests.xml) executes Context Information - Subscription unit tests associated 
to the robot files.
- [ContextSource Discovery Unit Tests](../.idea/runConfigurations/ContextSource_Discovery_Unit_Tests.xml) executes Context Source - Discovery unit tests associated to the robot 
files.
- [ContextSource Registration Unit Tests](../.idea/runConfigurations/ContextSource_Registration_Unit_Tests.xml) executes Context Source - Registration unit tests associated to the 
robot files.
- [ContextSource RegistrationSubscription Unit Tests](../.idea/runConfigurations/ContextSource_RegistrationSubscription_Unit_Tests.xml) executes Context Source - Registration Subscription unit 
tests associated to the robot files.
- [jsonldContext Consumption Unit Tests](../.idea/runConfigurations/jsonldContext_Consumption_Unit_Tests.xml) executes Storing, Managing and Serving @contexts - Consumption unit tests 
associated to the robot files.
- [jsonldContext Provision Unit Tests](../.idea/runConfigurations/jsonldContext_Provision_Unit_Tests.xml) executes Storing, Managing and Serving @contexts - Provision unit tests 
associated to the robot files.
- [Generate Documentation Data](../.idea/runConfigurations/Generate_Documentation_Data.xml) executes Generate Document Data unit tests associated to the unit test execution 
of a specific robot file (e.g. 047_01). The generated files are located in the [results](./results) folder.
- [Statistics Documentation Data](../.idea/runConfigurations/Statistics_Documentation_Data.xml) executes all the tests to generate the documentation and generate statistics about
the execution. The generated files are located in the [results](./results) folder, a special file called `testcases.json`
is generated with a list of all generated data.
