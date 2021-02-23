# Quick start guide

## Install Python & PIP   

* Install Python3 by running the following command:

```$ sudo dnf install python3``` (Ubuntu)

```$ brew install python3``` (MacOS)

* Confirm its installation with:   

```$ python --version``` (Ubuntu)

```$ python3 --version``` (MacOS)

* At this point, you can launch Python3 interpreter:    

```$ python``` (Ubuntu)

```$ python3``` (MacOS)

* Pip should be included by default. To confirm, run:   

```$ command -v pip``` (Ubuntu)

```$ pip3 --version``` (MacOS)

* In case pip is not installed, [follow the official pip installation guide](https://pip.pypa.io/en/latest/installing/).

## Install IDE (VSCode)

* Install [Visual Studio Code](https://code.visualstudio.com/docs/setup/linux)

* Install [Robot Framework Intellisense](https://marketplace.visualstudio.com/items?itemName=TomiTurtiainen.rf-intellisense)

## Checkout the base project   

```$ git clone git@forge.etsi.org:cim/ngsi-ld-test-suite.git```

## Configure the environment

In the `resources/variables.py` file, configure the following:
* URL of the context broker under test (including the `ngsi-ld/v1` path, e.g., http://localhost:8080/ngsi-ld/v1)
* Notification server host and port (an address accessible from the context broker)

## Install the project requirements

Browse the base project root folder and execute the following command:   

```$ python -m pip install -r requirements.txt``` (Ubuntu)

```$ python3 -m pip install -r requirements.txt``` (MacOS)

Further details on each library can be found in [PyPi](https://pypi.org/) and [Robot Framework Standard Libraries](http://robotframework.org/robotframework/#standard-libraries)

## Execute the tests

Configure the context broker URL in the resources/variables.py file

Launch the tests with the following command:

```$ robot --outputdir ./results .```   

For more running instructions please consult [scripts/run_tests.sh](https://github.com/easy-global-market/isg-cim-tpdl-demo/blob/rf-demo/scripts/run_tests.sh).

# Frameworks and libraries used in the project

* [Robot Framework](https://github.com/robotframework/robotframework)
* [RESTinstance](https://github.com/asyrjasalo/RESTinstance)
* [JSON Schema Library](https://github.com/jstaffans/robotframework-jsonschemalibrary)
* [JSON Library](https://github.com/robotframework-thailand/robotframework-jsonlibrary)
* [Requests Library](https://github.com/MarketSquare/robotframework-requests)
* [Deep Diff](https://github.com/seperman/deepdiff)

# Useful links   

* [Robot Framework User Guide](http://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#output-file)   
