#!/bin/bash

ARG0=$2

function bake(){
   cd cass3x/ && docker build -t diegopacheco/dwcass3x . --network=host && cd ../
   cd cass2x/ && docker build -t diegopacheco/dwcass2x . --network=host && cd ../
}

function run(){
   docker network create --subnet=128.18.0.0/16 myDWCassNetDocker

   docker run -d --net myDWCassNetDocker --ip 128.18.0.31 --name cassandra3x_1 --rm -ti diegopacheco/dwcass3x
   #docker run -d --net myDWCassNetDocker --ip 128.18.0.32 --name cassandra3x_2 --rm -ti diegopacheco/dwcass3x
   #docker run -d --net myDWCassNetDocker --ip 128.18.0.33 --name cassandra3x_3 --rm -ti diegopacheco/dwcass3x

   docker run -d --net myDWCassNetDocker --ip 128.18.0.21 --name cassandra2x_1 --rm -ti diegopacheco/dwcass2x
   #docker run -d --net myDWCassNetDocker --ip 128.18.0.22 --name cassandra2x_2 --rm -ti diegopacheco/dwcass2x
   #docker run -d --net myDWCassNetDocker --ip 128.18.0.23 --name cassandra2x_3 --rm -ti diegopacheco/dwcass2x
}

function stop(){
  docker stop cassandra3x_1
  docker stop cassandra3x_2
  docker stop cassandra3x_3
  docker stop cassandra2x_1
  docker stop cassandra2x_2
  docker stop cassandra2x_3
  docker network rm myDWCassNetDocker
}

function cql2x(){
  docker exec -ti cassandra2x_1 /cassandra/bin/cqlsh 128.18.0.21
}

function cql3x(){
  docker exec -ti cassandra3x_1 /cassandra/bin/cqlsh 128.18.0.31
}

function status2x(){
  docker exec -ti cassandra2x_1 /cassandra/bin/nodetool status
  docker exec -ti cassandra2x_2 /cassandra/bin/nodetool status
  docker exec -ti cassandra2x_3 /cassandra/bin/nodetool status
}

function status3x(){
  docker exec -ti cassandra3x_1 /cassandra/bin/nodetool status
  docker exec -ti cassandra3x_2 /cassandra/bin/nodetool status
  docker exec -ti cassandra3x_3 /cassandra/bin/nodetool status
}

function schema(){
  docker exec -ti cassandra2x_1 sh -c "echo \"
   CREATE KEYSPACE CLUSTER_TEST WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 3 };
   USE CLUSTER_TEST;
   CREATE TABLE TEST ( key text PRIMARY KEY, value text);
   INSERT INTO TEST (key,value) VALUES ('1', 'works');
   SELECT * from CLUSTER_TEST.TEST;\" | /cassandra/bin/cqlsh 128.18.0.21"

  docker exec -ti cassandra3x_1 sh -c "echo \"
    CREATE KEYSPACE CLUSTER_TEST WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 3 };
    USE CLUSTER_TEST;
    CREATE TABLE TEST ( key text PRIMARY KEY, value text);
    INSERT INTO TEST (key,value) VALUES ('1', 'works');
    SELECT * from CLUSTER_TEST.TEST;\" | /cassandra/bin/cqlsh 128.18.0.31"
}

function help(){
  echo "DualWrite-Cass-Docker: by Diego Pacheco"
  echo "bake                 : bake the docker image for Cass 2.x and 3.x "
  echo "run                  : run 2 Cass clusters(cass 2x and cass 3x)   "
  echo "stop                 : shutdown all dockers instances and network "
  echo "status2x             : nodetool status in all cass 2x nodes       "
  echo "status3x             : nodetool status in all cass 3x nodes       "
  echo "cql2x                : cqlsh in first cass 3x node                "
  echo "cql3x                : cqlsh in first cass 2x node                "
  echo "schema               : create same schema for cass 2x and 3x      "
}

case $1 in
     "bake")
          bake
          ;;
      "run")
          run
          ;;
      "stop")
          stop
          ;;
      "status2x")
          status2x
          ;;
      "status3x")
          status3x
          ;;
      "cql2x")
          cql2x
          ;;
      "cql3x")
          cql3x
          ;;
      "schema")
          schema
          ;;
      *)
          help
esac
