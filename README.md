# Quick start guide

## Install Python & PIP   

* Install Python3 by running the following command:

```$ sudo dnf install python3``` (Ubuntu)

```$ brew install python3``` (MacOS)

* Confirm its installation with:   

```$ python3 --version``` (Ubuntu)

```$ python3 --version``` (MacOS)

* At this point, you can launch Python3 interpreter:    

```$ python3``` (Ubuntu)

```$ python3``` (MacOS)

* Pip should be included by default. To confirm, run:   

```$ command -v pip``` (Ubuntu)

```$ pip3 --version``` (MacOS)

* In case pip is not installed, [follow the official pip installation guide](https://pip.pypa.io/en/latest/installing/).

## Install IDE (PyCharm)

* Install [PyCharm](https://www.jetbrains.com/fr-fr/pycharm/download)

* Install [Robot Framework Language Server](https://plugins.jetbrains.com/plugin/16086-robot-framework-language-server)

* Define as variable the path of the working directory: in Settings > Languages & Frameworks > Robot Framework (Project), 
insert the following: `{"EXECDIR": "{path}/auth-test-suite"}`

## Install IDE (VSCode)

* Install [Visual Studio Code](https://code.visualstudio.com/docs/setup/linux)

* Install [Robot Framework Intellisense](https://marketplace.visualstudio.com/items?itemName=TomiTurtiainen.rf-intellisense)

## Checkout the base project   

```$ git clone git@forge.etsi.org:cim/ngsi-ld-test-suite.git```

## Configure the environment

In the `resources/variables.py` file, configure the following:
* `url` : It is the url of the context broker which is to be tested (including the `ngsi-ld/v1` path, e.g., http://localhost:8080/ngsi-ld/v1).
* `notification_server_host` and `notification_server_port` : This is the address and port used to create the local server to listen to notifications (the address must be accessible by the context broker).
* `send_notification_server_host` and `send_notification_server_port` : This is the address and port used when creating the subscription on the context broker (generally it is the same information as `notification_server_host` and `notification_server_port`).
* `context_source_host` and `context_source_port` : The address and port used for the context source.

## Install the project requirements

Browse the base project root folder and execute the following command:   

```$ python3 -m pip install -r requirements.txt``` (Ubuntu)

```$ python3 -m pip install -r requirements.txt``` (MacOS)

Further details on each library can be found in [PyPi](https://pypi.org/) and [Robot Framework Standard Libraries](http://robotframework.org/robotframework/#standard-libraries)

## Run configurations (PyCharm)

Two sample configurations have been created:

- one to check if there are syntax or format changes to be done according to Robotidy (`Check Format`)
- one to make the syntax and format changes according to Robotidy (`Format Files`)

To launch a run configuration, choose one of the two configurations from the Run menu and click on it to run it.

## Pre commit

Before each commit, a formatting according to the rules of [Robotidy](https://github.com/MarketSquare/robotframework-tidy)
 is done for files with the `.robot` or `.resource` extension. If nothing has been modified, the commit is done normally.
 Otherwise, the commit displays an error message with all the modifications made by Robotidy to format the file. Modified
 files can then be added to the commit.

To use it, install `pre-commit` with the following commands (using pip):

```$ pip install pre-commit```

Then install the Git hook scripts:

```$ pre-commit install```

Now, it will run automatically on every commit.

To manually launch the tool, the following command can be used:

```$ ./venv/bin/python -m robotidy .```

Further details can be found on the [pre-commit](https://pre-commit.com) site.

## Execute the tests

Configure the context broker URL in the resources/variables.py file

Launch the tests with the following command:

```$ robot --outputdir ./results .```   

For more running instructions please consult [scripts/run_tests.sh](./scripts/run_tests.sh).

## Generate a documentation for the support keywords

```$ python3 -m robot.libdoc resources/ApiUtils.resource api_docs/ApiUtils.html```

## Generate a documentation for the Test Cases

```$ python3 -m robot.testdoc TP/NGSI-LD api_docs/TestCases.html```

# Frameworks and libraries used in the project

* [Robot Framework](https://github.com/robotframework/robotframework)
* [JSON Library](https://github.com/robotframework-thailand/robotframework-jsonlibrary)
* [Requests Library](https://github.com/MarketSquare/robotframework-requests)
* [Deep Diff](https://github.com/seperman/deepdiff)
* [HttpCtrl Library](https://github.com/annoviko/robotframework-httpctrl)
* [Robotidy Library ](https://github.com/MarketSquare/robotframework-tidy)

# Useful links   

* [Robot Framework User Guide](http://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#output-file)   
