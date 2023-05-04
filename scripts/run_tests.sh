#!/bin/bash

# run all tests
robot --outputdir ./results ./TP/NGSI-LD

# run all tests with base url overriden
robot --variable url:"URL_HERE" --outputdir ./results .

# run by specific tag(s)
robot --include mandatory --outputdir ./results .

# run all the tests for context information
robot --outputdir ./results ./TP/NGSI-LD/ContextInformation

# run a specific test case
robot --outputdir ./results ./TP/NGSI-LD/ContextInformation/Provision/Entities/CreateEntity/001_01.robot
robot --outputdir ./results --suite 001_01 .

# run specific test case
robot --outputdir ./results -t "SuccessCases_MinimalEntity"
robot --outputdir ./results -t "SuccessCases_MinimalEntity" ./TP/NGSI-LD/ContextInformation/Provision/Entities/CreateEntity/SuccessCases.robot

# rerun failed tests
robot --rerunfailedsuites ./results/output.xml  --outputdir ./results .

# stop the suite after a failed test
robot --exitonfailure --outputdir ./results . 
