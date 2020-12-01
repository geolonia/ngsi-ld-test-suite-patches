*OS: Linux*

#### Install Python & PIP   

* Install Python3 by running the following command:   
```$ sudo dnf install python3```
* Confirm its installation with:   
```$ python --version```
* At this point, you can launch Python3 interpreter:    
```$ python```
* Pip should be included by default. To confirm, run:   
```$ command -v pip```   
* In case pip is not installed, [follow the official pip installation guide](https://pip.pypa.io/en/latest/installing/).

#### Install IDE (VSCode)
* Install Visual Studio code (https://code.visualstudio.com/docs/setup/linux)

* Install [Robot Framework Intellisense](https://marketplace.visualstudio.com/items?itemName=TomiTurtiainen.rf-intellisense)

#### Checkout the base project   
```$ git clone git@forge.etsi.org:cim/ngsi-ld-test-suite.git```

#### Install the project requirements
Browse the base project root folder and execute the following command:   

```$ sudo python -m pip install -r requirements.txt```    

Further details on each library can be found in [PyPi](https://pypi.org/) and [Robot Framework Standard Libraries](http://robotframework.org/robotframework/#standard-libraries)

#### Execute the tests
```$ robot --outputdir ./results .```   

For more running instructions please consult [scripts/run_tests.sh](https://github.com/easy-global-market/isg-cim-tpdl-demo/blob/rf-demo/scripts/run_tests.sh).

#### Useful links   
* [Robot Framework User Guide](http://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#output-file)   
