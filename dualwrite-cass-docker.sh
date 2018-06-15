#!/bin/bash

ARG0=$2

function bake(){
   docker network create --subnet=128.18.0.0/16 myDWCassNetDocker
   cd cass3x/ && docker build -t diegopacheco/dwcass3x . --network=host && cd ../
   cd cass2x/ && docker build -t diegopacheco/dwcass2x . --network=host && cd ../
}

function run(){
   #docker run -d --net myDWCassNetDocker --ip 128.18.0.31 --name cassandra3x_1 --rm -ti diegopacheco/dwcass3x
   #docker run -d --net myDWCassNetDocker --ip 128.18.0.32 --name cassandra3x_2 --rm -ti diegopacheco/dwcass3x
   #docker run -d --net myDWCassNetDocker --ip 128.18.0.33 --name cassandra3x_3 --rm -ti diegopacheco/dwcass3x

   docker run -d --net myDWCassNetDocker --ip 128.18.0.21 --name cassandra2x_1 --rm -ti diegopacheco/dwcass2x
   docker run -d --net myDWCassNetDocker --ip 128.18.0.22 --name cassandra2x_2 --rm -ti diegopacheco/dwcass2x
   docker run -d --net myDWCassNetDocker --ip 128.18.0.23 --name cassandra2x_3 --rm -ti diegopacheco/dwcass2x
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

function help(){
  echo "DualWrite-Cass-Docker: by Diego Pacheco"
  echo "bake                 : bake the docker image for Cass 2.x and 3.x "
  echo "run                  : run 2 Cass clusters(cass 2x and cass 3x)   "
  echo "stop                 : shutdown all dockers instances and network "
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
      *)
          help
esac
