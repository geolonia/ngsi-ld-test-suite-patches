#!/bin/bash

#run all tests
robot --outputdir ./results .

#run all tests with base url overriden
#robot --variable url:"URL_HERE" --outputdir ./results .

#specify which tests are critical
#robot --critical critical --outputdir ./results .

#run by specific tag(s)
#robot --include critical --outputdir ./results .

#run specific test suite
#robot --outputdir ./results ./TP/NGSI-LD/ContextInformation
#robot --outputdir ./results ./TP/NGSI-LD/ContextInformation/Provision/Entities/CreateEntity/SuccessCases.robot

#run specific test case
#robot --outputdir ./results -t "SuccessCases_MinimalEntity"
#robot --outputdir ./results -t "SuccessCases_MinimalEntity" ./TP/NGSI-LD/ContextInformation/Provision/Entities/CreateEntity/SuccessCases.robot

#rerun failed tests
#robot --rerunfailedsuites ./results/output.xml  --outputdir ./results .

#stop the suite after a failed test
robot --exitonfailure --outputdir ./results . 
