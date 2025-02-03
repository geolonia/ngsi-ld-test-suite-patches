# PLUG TEST Configuration

You can found a docker compose for easy launching of : orion-ld, scorpio and stellio in their respective directory.

you will need to define the following environment variable before launching the docker compose :
- PORT : the port behind which the broker will be deployed
- DB_PORT : the port behind which the database will be deployed
- SUFFIX : an addition to the name of the container to easily deploy multiple instances.

then you can launch the docker compose 
```
cd plug-test
cd stellio
PORT=8080 DB_PORT=5432 SUFFIX="-1" docker compose -p first_broker  up
```

by changing the variables you can easilly launch a second instance of a broker 
```
cd plug-test
cd stellio
PORT=8081 DB_PORT=5433 SUFFIX="-2" docker compose -p second_broker  up
```

if you are a windows user or prefer using an .env file you can use the .example.env file to set the variable instead.

## CAVEAT with localhost and docker (for non leaf brokers)

An application running on a container will not be able to contact another container on http://localhost:$PORT
It may need to call http://container-name:$PORT instead.

Another solution is to put the network mode to "host" in the docker-compose, but it can lead to some port conflict if you have multiple instances
