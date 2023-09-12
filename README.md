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

```$ curl https://forge.etsi.org/rep/cim/ngsi-ld-test-suite/-/raw/windows11/scripts/configure.sh > configure.sh```

- For Windows, using Powershell download the following file (curl is an alias for Invoke-WebRequest in Powershell):

```> curl https://forge.etsi.org/rep/cim/ngsi-ld-test-suite/-/raw/windows11/scripts/configure.ps1 > configure.ps1```

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

- `url` : It is the url of the context broker which is to be tested (including the `ngsi-ld/v1` path, 
e.g., http://localhost:8080/ngsi-ld/v1).
- `notification_server_host` and `notification_server_port` : This is the address and port used to create the local 
server to listen to notifications (the address must be accessible by the context broker). 
Default value: `0.0.0.0` and `8085`.
- `send_notification_server_host` and `send_notification_server_port` : This is the address and port used when 
creating the subscription on the context broker (generally it is the same information as `notification_server_host` 
and `notification_server_port`). Default value: `0.0.0.0` and `8085`.
- `context_source_host` and `context_source_port` : The address and port used for the context source. 
Default value: `0.0.0.0` and `8086`.

When you execute locally the tests, you can leave the default values as they are. NGSI-LD Test Suite provides
some mockup services to provide the required functionality.


## Execute the NGSI-LD Test Suite

The first operation that you have to develop is the activation of the Python Virtual Environment through the
execution of the following command in MacOS or Ubuntu:

```$ source .venv/bin/activate```

In case of Windows, you need to execute the following command:

```> .\.venv\scripts\activate.bat ```

Now, you can launch the tests with the following command in MacOS or Linux:

```$ robot --outputdir ./results .```  

For Windows system, you can lauch the tests with the following command:

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

If you want to generate a documentation for the support keywords:

```$ python3 -m robot.libdoc resources/ApiUtils.resource api_docs/ApiUtils.html```

If you want to generate a documentation for the Test Cases:

```$ python3 -m robot.testdoc TP/NGSI-LD api_docs/TestCases.html```

And if you want to tidy the Test Cases:

```$ python3 -m robot.tidy --recursive TP/NGSI-LD```

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


## Contribute to the Test Suite

In order to contribute to the ETSI NGSI-LD Test Suite, you recommend the installation of an IDE with the corresponding
Robot Framework. Our recommendations are:

- PyCharm


### Install IDE (PyCharm)

- Install [PyCharm](https://www.jetbrains.com/fr-fr/pycharm/download)

- Install [Robot Framework Language Server](https://plugins.jetbrains.com/plugin/16086-robot-framework-language-server)

- Define as variable the path of the working directory. In Settings > Languages & Frameworks > Robot Framework (Project), 
insert the following: `{"EXECDIR": "{path}/auth-test-suite"}`


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
python3 scripts/find_unused_test_data.py
```

### Find and run Test Cases using a given test data file

The `find_tc_using_test_data.py` script in the `scripts` directory can be used to find the Test Cases that are using a 
given test data file. It can optionally run all the matching Test Cases:

```
python3 scripts/find_tc_using_test_data.py
```

When launched, the script asks for a test date file name and if the matching Test Cases should be executed.

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
