#!/bin/bash

ARG0=$2
ARG1=$3
ARG2=$4

function bake(){
   cd cass3x/ && docker build -t diegopacheco/dwcass3x . --network=host && cd ../
   cd cass2x/ && docker build -t diegopacheco/dwcass2x . --network=host && cd ../
}

function run(){
   docker network create --subnet=128.18.0.0/16 myDWCassNetDocker

   docker run -d --net myDWCassNetDocker --ip 128.18.0.31 -p 30131:9042 --name cassandra3x_1 --rm -ti diegopacheco/dwcass3x
   #docker run -d --net myDWCassNetDocker --ip 128.18.0.32 -p 30132:9042 --name cassandra3x_2 --rm -ti diegopacheco/dwcass3x
   #docker run -d --net myDWCassNetDocker --ip 128.18.0.33 -p 30123:9042 --name cassandra3x_3 --rm -ti diegopacheco/dwcass3x

   docker run -d --net myDWCassNetDocker --ip 128.18.0.21 -p 30121:9042 --name cassandra2x_1 --rm -ti diegopacheco/dwcass2x
   #docker run -d --net myDWCassNetDocker --ip 128.18.0.22 -p 30122:9042 --name cassandra2x_2 --rm -ti diegopacheco/dwcass2x
   #docker run -d --net myDWCassNetDocker --ip 128.18.0.23 -p 30123:9042 --name cassandra2x_3 --rm -ti diegopacheco/dwcass2x
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

function ssh(){
  version="${ARG0}"
  node="${ARG1}"
  docker_instance="cassandra${version}x_${node}"
  docker_ip="128.18.0.${version}${node}"
  echo "SSH Cassandra $docker_instance on IP $docker_ip"
  docker exec -ti $docker_instance bash
}

function memory(){
  memory21=$(docker exec -ti cassandra2x_1 /bin/sh -c "ps aux | awk '{print \$6/1024 \" MB\t\t\" \$11}'  | sort -n | grep java | awk '{print \$1 \" \" \$2}'")
  memory31=$(docker exec -ti cassandra3x_1 /bin/sh -c "ps aux | awk '{print \$6/1024 \" MB\t\t\" \$11}'  | sort -n | grep java | awk '{print \$1 \" \" \$2}'")
  echo "|Cass 2x - 128.18.0.21 -> $memory21 "
  echo "|Cass 3x - 128.18.0.31 -> $memory31 "
}

function count(){
  echo "Cass 2x - 128.18.0.21 - keys count: "
  docker exec -ti cassandra2x_1 sh -c "echo \"select COUNT(*) from cluster_test.test ;\" | /cassandra/bin/cqlsh --request-timeout=6000 128.18.0.21"
  echo "Cass 3x - 128.18.0.31 - keys count: "
  docker exec -ti cassandra3x_1 sh -c "echo \"select COUNT(*) from cluster_test.test ;\" | /cassandra/bin/cqlsh --request-timeout=6000 128.18.0.31"
}

function truncate(){
  echo "Cass 2x - 128.18.0.21 - TRUNCATE: "
  docker exec -ti cassandra2x_1 sh -c "echo \"TRUNCATE cluster_test.test ;\" | /cassandra/bin/cqlsh --request-timeout=6000 128.18.0.21"
  echo "Cass 3x - 128.18.0.31 - TRUNCATE: "
  docker exec -ti cassandra3x_1 sh -c "echo \"TRUNCATE cluster_test.test ;\" | /cassandra/bin/cqlsh --request-timeout=6000 128.18.0.31"
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
    SELECT * from CLUSTER_TEST.TEST;\" | /cassandra/bin/cqlsh 128.18.0.31"
}

function info(){
  echo "Cass 2.2.12 Topology: "
  echo "--- 128.18.0.21:30121"
  echo "--- 128.18.0.22:30122"
  echo "--- 128.18.0.23:30123"
  echo "Cass 3.9 Topology: "
  echo "--- localhost:30131"
  echo "--- localhost:30132"
  echo "--- localhost:30133"
}

function help(){
  echo "DualWrite-Cass-Docker: by Diego Pacheco"
  echo "bake                 : bake the docker image for Cass 2.x and 3.x   "
  echo "run                  : run 2 Cass clusters(cass 2x and cass 3x)     "
  echo "stop                 : shutdown all dockers instances and network   "
  echo "status2x             : nodetool status in all cass 2x nodes         "
  echo "status3x             : nodetool status in all cass 3x nodes         "
  echo "cql2x                : cqlsh in first cass 3x node                  "
  echo "cql3x                : cqlsh in first cass 2x node                  "
  echo "memory               : Show how much memory each cass node is using "
  echo "ssh                  : SSH/Bash Cass Node. i.e: ssh 3 1 for cass3x node 1 - ssh 2 1 for cass2x node 1 "
  echo "count                : Count how many records in Cass 2x and 3x     "
  echo "schema               : create same schema for cass 2x and 3x        "
  echo "truncate             : truncate table TEST from cass 2x and 3x      "
  echo "info                 : show info about cass 2x and 3x topology      "
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
      "memory")
          memory
          ;;
      "ssh")
          ssh
          ;;
      "count")
          count
          ;;
      "schema")
          schema
          ;;
      "truncate")
          truncate
          ;;
      "info")
          info
          ;;
      *)
          help
esac
