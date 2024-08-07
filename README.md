# ETSI NGSI-LD Test Suite

This repository contains the ETSI NGSI-LD Test Suite to test the compliance of the Context Brokers with the
specification of the ETSI NGSI-LD API.

## Contents

<details>

<summary><strong>Details</strong></summary>

-   [Install the Test Suite](#install-the-test-suite)
-   [Configure the test suite](#configure-the-test-suite)
-   [Execute the NGSI-LD Test Suite](#execute-the-ngsi-ld-test-suite)
-   [Contribute to the Test Suite](#contribute-to-the-test-suite)
    -   [Install IDE (PyCharm)](#install-ide-pycharm)
    -   [Run configurations (PyCharm)](#run-configurations-pycharm)
    -   [Pre commit](#pre-commit)
-   [Tooling](#tooling)
-   [Frameworks and libraries used in the project](#frameworks-and-libraries-used-in-the-project)
-   [Useful links](#useful-links)   
-   [LICENSE](#license)

</details>


## Install the Test Suite

In order to install the ETSI NGSI-LD Test Suite, download the configuration script:

- For MacOS and Ubuntu, download the following file:

```$ curl https://forge.etsi.org/rep/cim/ngsi-ld-test-suite/-/raw/develop/scripts/configure.sh > configure.sh```

- For Windows, using Powershell download the following file (curl is an alias for Invoke-WebRequest in Powershell):

```> curl https://forge.etsi.org/rep/cim/ngsi-ld-test-suite/-/raw/develop/scripts/configure.ps1 > configure.ps1```

- For MacOS and Ubuntu, be sure that you have the proper execution permissions of the file and the user is included 
in the sudoers group, then execute the following script:

```$ configure.sh```

- In Windows 11, using Powershell, make sure you can run the script:

```> powershell -executionpolicy bypass configure.ps1```

These scripts develop a set of operations, the same in the different Operating System, which consist of:
- Installation of the corresponding software requirements:
  - Python3.11
  - Git
  - Virtualenv
  - Pip
- Cloning the NGSI-LD Test Suite repository in the local folder and create the corresponding Python Virtual Environment
taking into account the content of `requirements.txt` file. Further details on each library can be found in 
[PyPi](https://pypi.org/) and 
[Robot Framework Standard Libraries](http://robotframework.org/robotframework/#standard-libraries).


## Configure the test suite

In the `resources/variables.py` file, configure the following parameters:

- `url` : It is the url of the context broker which is to be tested (including the `/ngsi-ld/v1` path, 
e.g., http://localhost:8080/ngsi-ld/v1).
- `temporal_api_url` : This is the url of the GET temporal operation API, in case that a Context Broker splits 
this portion of the API (e.g., http://localhost:8080/ngsi-ld/v1).
- `ngsild_test_suite_context` : This is the url of the default context used in the ETSI NGSI-LD requests 
(e.g., 'https://forge.etsi.org/rep/cim/ngsi-ld-test-suite/-/raw/develop/resources/jsonld-contexts/ngsi-ld-test-suite-compound.jsonld').
- `notification_server_host` and `notification_server_port` : This is the address and port used to create the local 
server to listen to notifications (the address must be accessible by the context broker). 
Default value: `0.0.0.0` and `8085`.
- `context_source_host` and `context_source_port` : The address and port used for the context source. 
Default value: `0.0.0.0` and `8086`.
- `context_server_host` and `context_server_port` : The address and port used for the context server provider. 
Default value: `0.0.0.0` and `8087`.
- `core_context`: The default cached core context used by the Brokers.

When you execute locally the tests, you can leave the default values as they are. NGSI-LD Test Suite provides
a mockup services to provide the notification functionality and therefore the notification_server_host can be
assigned to '0.0.0.0'. In case that you deploy the Context Broker on a docker engine, you need to specify the
url of the Docker Host. In this case you have two options to specify the IP address of your host machine:

- (Windows, MacOS) As of Docker v18.03+ you can use the `host.docker.internal` hostname to connect to your 
Docker host.
- (Linux) Need to extract the IP of the `docker0` interface. Execute the following command:
``` ifconfig docker0 | grep inet | awk '{print $2}' ``` and that IP is the one that you need to use for 
notification purposes.

Optionally, there are some extra variables that can be used during the generation of execution results of the Test 
Case with a specific Robot Listener class to automatically generate a GitHub Issue in the GitHub repository of the 
Context Broker of a failed Test Case. In case that you cannot or do not want to use this functionality, delete those 
variables from the file.

As an explanation of the process, the GitHub Issue will be created if there is no other issue in the repository with
the same name or there is an issue with the same name, but it is not closed.

In order to create these issues, the [GitHub REST API](https://docs.github.com/en/rest) is used. For this purpose, 
the authentication process is using a personal access token. The needed variables are the following:
* `github_owner`: Your GitHub user account. 
* `github_broker_repo` : The corresponding URL of the Context Broker repository.
* `github_token` : Your personal access token. Please take a look to the GitHub documentation if you want to generate 
your own [personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens).

## Execute the NGSI-LD Test Suite

The first operation that you have to develop is the activation of the Python Virtual Environment through the
execution of the following command in MacOS or Ubuntu:

```$ source .venv/bin/activate```

In case of Windows, you need to execute the following command:

```> .\.venv\scripts\activate.bat ```

Now, you can launch the tests with the following command in MacOS or Linux:

```$ robot --outputdir ./results .```  

For Windows system, you can launch the tests with the following command:

```> robot --outputdir .\results .\TP\NGSI-LD```

For more running instructions, please consult [scripts/run_tests.sh](./scripts/run_tests.sh) or [scripts/run_tests.ps1](./scripts/run_tests.ps1)

To have the whole messages, it is necessary to modify the width of the test execution output with the option 
--consolewidth (-W). The default width is 78 characters.

```$ robot --consolewidth 150  .```

The messages in the console are clear and without noise, only the strictly necessary (request and response to the 
Context Brokers and a nice message which shows the difference between two documents when they are). However, it can be 
difficult to follow all the messages in the console when there is a lot of testing and a lot of Context Broker calls. 
This is why a command to redirect the console output to a file can be used. You must add a chevron at the end of the 
test launch command followed by the file name.

```$ robot . > results.log```

> **Note:** if you want to deactivate the Python Virtual Environment just execute the command in 
> MacOS and Ubuntu systems:
> 
> ```console
> $ deactivate
> ```
> And in Window system:
> 
> ```console
> > .venv\scripts\deactivate.bat
> ```

### Specific test requirements
- Mqtt tests (058) : 
  - Mqtt tests launch a mosquitto container with docker thus it requires docker to be installed and running


- Temporal pagination (020_13, 020_14, 021_15 & 021_16) :
  - The pagination tests assumes that it will be triggered by 1 or 2 entities with 2 attributes with 20 instances each
    (40 instances)
  - Non pagination tests assumes that it will **not** be triggered by 2 entities with 2 attributes with 5 instances each
    (20 instances)
  - You should configure your broker accordingly


## Test Suite Management (tsm)

The `tsm` script is designed to facilitate the selection and execution of the Test Suite, especially if not all the 
endpoints of the API have been implemented for a specific Context Broker. This script provides a set of commands 
to enable or disable Test Cases, Robot Test Suites or Collections (Robot Test Suite Groups), visualize the current 
status of the different Test Cases, execute the selected Test Cases and perform other related operations as described 
below.

The `tsm` script generates a pickle file named `tsm.pkl`, which stores the tuples list corresponding to each Test Case 
with the following information:

    (switch, running status, Test Case long name)

where the values and their meaning are the following:
* **switch**:
  * `ON`: the Test Case is on, which means that it will be executed by the script.
  * `OFF`: the Test Case is off, and therefore is not selected to be executed by the script.
  * `MISSING`: the Test Case is not anymore in the Test Suite Structure. An update operation should be run to update 
  the `tsm.pkl` with the current set of available Test Cases in the filesystem.
  * `NEW`:  new Test Case discovered by the tsm after an update operation.
* **status**:
  * `PASSED`: the robot framework executes the Test Case with result PASS.
  * `FAILED`: the robot framework executes the Test Case with result FAIL.
  * `PENDING`: the Test Case is pending to be executed by the robot framework.
* **test case long name**: the Test Case long name set by robot framework based on the Robot Test Suite number and 
the Test Case name (e.g., NGSILD.032 02.032_02_01 Delete Unknown Subscription)

### Installation
The `tsm` script is integrated with arguments auto-completion for bash, therefore it is needed the installation of 
the argcomplete python package on your system:

    pip install argcomplete

and to enable the completion after the installation executing the following command:

    activate-global-python-argcomplete 

and then 

    eval "$(register-python-argcomplete tsm)"

Now, it is possible to autocomplete the commands and show possible options executing the script. Also –help argument 
is available to obtain more information about the options.

### Execution

The tsm cases update command updates the `tsm.pkl` file with all the Robot Test Suite under the local path. If the 
pickle file does not exist, it is created. After the creation of this file, it is possible to execute the script 
to maintain and run the selected Test Cases from the pickle file. The list of commands is the following:

* **Test Cases (cases)**
  * Switch ON Test Cases
  
        tsm cases on [test_cases]
  
  * Switch OFF Test Cases

        tsm cases off [test_cases]
        tsm cases off "NGSILD.032 01.032_01_02 InvalidId"
  
  * List Test Cases based on the specific flag.
        
        tsm cases list [on, off, missing, new, passed, failed, pending, all]
        tsm cases list ./TP/NGSI-LD/CommonBehaviours
  
  * Run Test Cases that are enabled

        tsm cases run [on, off, missing, new, passed, failed, pending, [test_cases]]
        tsm cases run NGSILD.048\ 01.048_01_06\ Endpoint\ post\ /temporal/entities/
        tsm cases run pending
      
  * Update the pickle file with the current Test Cases

        tsm cases update
       
  * Clean Test Cases, remove the Test Cases that were marked as MISSING

        tsm cases clean

* **Robot Test Suites (suites)**
  * Switch ON Robot Test Suites

        tsm suites on [suites]
       
  * Switch OFF Robot Test Suites

        tsm suites off [suites]

* **Test Collections (collections)**
  * Switch ON Test Collections

        tsm collections on [collections]
        tsm collections on ./TP/NGSI-LD/CommonBehaviours

  * Switch OFF Test Collections

        tsm collections off [collections]

## Contribute to the Test Suite

In order to contribute to the ETSI NGSI-LD Test Suite, it is recommended to install an IDE with the corresponding
Robot Framework. Our recommendations are:

- PyCharm


### Install IDE (PyCharm)

- Install [PyCharm](https://www.jetbrains.com/fr-fr/pycharm/download)

- Install [Robot Framework Language Server](https://plugins.jetbrains.com/plugin/16086-robot-framework-language-server)

- Define as variable the path of the working directory. In Settings > Languages & Frameworks > Robot Framework 
(Project), insert the following: `{"EXECDIR": "{path}/ngsi-ld-test-suite"}`.

### Develop a new Test Case

In order to develop a new Test Case, some rules and conventions have to be followed.

#### Test Case Template

The following template shows the typical structure of a Test Case. It can be used as a template when creating a new
Test Case.

```
*** Settings ***
Documentation       {Describe the behavior that is being checked by this Test Case}

Resource            ${EXECDIR}/resources/any/necessary/resource/file

# For both setup and teardown steps, try as possible to use Keyword names already declared in doc/analysis/initial_setup.py
Suite Setup         {An optional setup step to create data necessary for the Test Case}
Suite Teardown      {An optional teardown step to delete data created in the setup step}
Test Template       {If the Test Case uses permutations, the name of the Keyword that is called for each permutation}


*** Variables ***
${my_variable}=             my_variable


*** Test Cases ***    PARAM_1    PARAM_2
XXX_YY_01 Purpose of the first permutation
    [Tags]    {resource_request_reference}    {section_reference_1}    {section_reference_2}
    param_1_value    param_2_value
XXX_YY_02 Purpose of the second permutation
    [Tags]    {resource_request_reference}    {section_reference_1}    {section_reference_2}
    param_1_value    param_2_value


*** Keywords ***
{Keyword name describing what the Test Case is doing} 
    [Documentation]    {Not sure this documentation brings something?}
    [Arguments]    ${param_1}    ${param_2}
    
    # Call operation that is being tested, passing any needed argument

    # Perform checks on the response that has been received from the operation
    
    # Optionally call another endpoint to do extra checks (e.g. check an entity has really been created)

# Add there keywords for setup and teardown steps
# Setup step typically creates data necessary for the Test Case and set some variables that will be used by the Test Case
# using Set Suite Variable or Set Test Variable keywords
# Teardown step must delete any data that has been created in setup step
```

Where :

- The possible values for `{resource_request_reference}` are defined in DGR/CIM-0015v211, section 6.1
- The meaning of the `{section_reference_x}` tags is defined in DGR/CIM-0015v211, section 6.2. A Test Case can reference
  more than one section in the specification (for instance, a Test Case whose goal is to check that scopes are correctly
  created when an entity is created should reference sections 4.18 NGSI-LD Scopes and 5.6.1 Create Entity of the 
  RGS/CIM-009v131 document)

#### Generate the documentation

The Conformance Tests include an option to automatically generate the documentation of them. If new tests are developed 
but include the Check and Request operations already defined, it is not needed to modify the automatic generation system. 
Nevertheless, if there are new operations to check and/or new request operations to develop in the Conformance Tests, 
it is needed to describe them so that the automatic documentation generated covers these new operations.

Additionally, there is defined a Unit Test mechanism to identify if new Test Suites are included in the system 
(See `doc/tests/test_CheckTests.py`) and if there were some changes in any Test Suite (See the `doc/tests/other test_*.py`). 
In these cases, it is needed to provide the corresponding information in the Python code:

- When a new Test Case is created, it has to be declared in the corresponding `doc/tests/test_{group}.py` Python file
  (where `{group}` represents the group of operations and how they are defined in the ETSI RGS/CIM-0012v211 document). 
  Complementary to this, updates have to be done:
  - In `doc/analysis/initial_setup.py` if it uses a new keyword to set up the initial state of the Test Case
  - In `doc/analysis/requests.py` if it updates an endpoint operation, for instance by adding support for a new request
    parameter (in `self.op` with the list and position of parameters, in the method that pretty prints the operation in 
    the automated generation of the documentation associated with the Test Cases. If the positions array is empty, it 
    means that all the parameters will be taken into consideration)
  - Run the documentation generation script (`python doc/generateDocumentationData.py {new_tc_id}`) for the new Test 
    Case and copy the generated JSON file in the folder containing all files for the given group and subgroup 
    (`cp doc/results/{new_tc_id}.json doc/files/{group}/{subgroup}`)
- When a new global Keyword is created, it has to be declared in the corresponding Python files:
  - In `doc/analysis/checks.py` if it is an assertion type keyword (in `self.checks` to reference the method that pretty
    prints the operation and `self.args` to identify the position of the arguments) and the corresponding method to 
    provide the description of this new operation
  - In `doc/analysis/requests.py` if it is an endpoint operation (in `self.op` with the list and position of parameters,
    in `self.description` to reference the method that pretty print the operation, and add the method that pretty prints
    the operation)
- When a new permutation is added in an existing Test Case, run the documentation generation script 
  (`python doc/generateDocumentationData.py {tc_id}`) for the Test Case and copy the generated JSON file in the 
  folder containing all files for the given group and subgroup (`cp doc/results/{tc_id}.json doc/files/{group}/{subgroup}`)
- When a new directory containing Test Cases is created, it has to be declared in `doc/generaterobotdata.py` along with
  its acronym

Finally, check that everything is OK by running the unit tests:

```shell
python -m unittest discover -s ./doc/tests -t ./doc
```

### Run configurations (PyCharm)

Two sample configurations have been created:

- one to check if there are syntax or format changes to be done according to Robotidy (`Check Format`)
- one to make the syntax and format changes according to Robotidy (`Format Files`)

To launch a run configuration, choose one of the two configurations from the Run menu and click on it to run it.


### Pre commit

Before each commit, a formatting according to the rules of 
[Robotidy](https://github.com/MarketSquare/robotframework-tidy) is done for files with the `.robot` or `.resource` 
extension. If nothing has been modified, the commit is done normally. Otherwise, the commit displays an error message 
with all the modifications made by Robotidy to format the file. Modified files can then be added to the commit.

To use it, install `pre-commit` with the following commands (using pip):

```$ pip install pre-commit```

Then install the Git hook scripts:

```$ pre-commit install```

Now, it will run automatically on every commit.

To manually launch the tool, the following command can be used:

```$ python -m robotidy .```

Further details can be found on the [pre-commit](https://pre-commit.com) site.

## Tooling

### Find unused test data files

The `find_unused_test_data.py` script in the `scripts` directory can be used to get a list of the test data files
that are not used by any Test Case:

```
$ python3 scripts/find_unused_test_data.py
```

### Find and run Test Cases using a given test data file

The `find_tc_using_test_data.py` script in the `scripts` directory can be used to find the Test Cases that are using a 
given test data file. It can optionally run all the matching Test Cases:

```
$ python3 scripts/find_tc_using_test_data.py
```

When launched, the script asks for a test date file name and if the matching Test Cases should be executed.

### Find the list of defined Variables and Keywords in all resources files

The `apiutils.py` script in the `scripts` directory can be used to find the Variables and Keywords that are defined
in all resources files defined in the folder `resources/ApiUtils`.

```
$ python3 scripts/apiutils.py
```

### Generate documentation content

If you want to generate a documentation for the support keywords, for example for Context Information Consumption 
resources:

```$ python3  -m robot.libdoc  resources/ApiUtils/ContextInformationConsumption.resource  api_docs/ContextInformationConsumption.html```

And, if you want to generate a documentation for the Test Cases:

```$ python3  -m robot.testdoc  TP/NGSI-LD  api_docs/TestCases.html```

## Generate output file details only for failed tests

It is possible to generate a report only for the failed tests through the use of a specific listener in the execution
of the robot framework. For example, if you want to execute the test suite number 043 and generate the report, you can
execute the following command:

```robot  --listener libraries/ErrorListener.py --outputdir ./results ./TP/NGSI-LD/CommonBehaviours/043.robot```

It will generate a specific `errors.log` file into the `results` folder with the description of the different steps 
developed and the mismatched observed on them.

## Coding Style of Test Suites

And if you want to tidy (code style) the Test Suites:

```$ python3  -m robot.tidy  --recursive TP/NGSI-LD```


## Frameworks and libraries used in the project

* [Robot Framework](https://github.com/robotframework/robotframework)
* [JSON Library](https://github.com/robotframework-thailand/robotframework-jsonlibrary)
* [Requests Library](https://github.com/MarketSquare/robotframework-requests)
* [Deep Diff](https://github.com/seperman/deepdiff)
* [HttpCtrl Library](https://github.com/annoviko/robotframework-httpctrl)
* [Robotidy Library ](https://github.com/MarketSquare/robotframework-tidy)


## Useful links

* [Robot Framework User Guide](http://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#output-file)   


## LICENSE

Copyright 2021 ETSI

The content of this repository and the files contained are released under the [ETSI Software License](LICENSE) a 
(BSD-3-Clause LICENSE).