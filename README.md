# dualwrite-cass-docer

dualwrite-cass-docer: Docker images that bootup 2 clusters(cass 2x and 3x) at same time.

# How to Use it?

## Avaliable commands
```bash
DualWrite-Cass-Docker: by Diego Pacheco
bake                 : bake the docker image for Cass 2.x and 3.x   
run                  : run 2 Cass clusters(cass 2x and cass 3x)     
stop                 : shutdown all dockers instances and network   
status2x             : nodetool status in all cass 2x nodes         
status3x             : nodetool status in all cass 3x nodes         
cql2x                : cqlsh in first cass 3x node                  
cql3x                : cqlsh in first cass 2x node                  
memory               : Show how much memory each cass node is using
ssh                  : SSH/Bash Cass Node. i.e: ssh 3 1 for cass3x node 1 - ssh 2 1 for cass2x node 1
count                : Count how many records in Cass 2x and 3x     
schema               : create same schema for cass 2x and 3x        
truncate             : truncate table TEST from cass 2x and 3x      
info                 : show info about cass 2x and 3x topology
```

## BAKE
In  order to use it we need bake 2 docker images - just 1 time.
```bash
./dualwrite-cass-docker.sh bake
```

## Run
Run will bootup 2 cass clusters(2x and 3x)
```bash
./dualwrite-cass-docker.sh run
```
```bash
./dualwrite-cass-docker.sh run
e62aba9e90ad3049d92f45db82145154e16a1d7ca83d52026174f4630f2efb1a
d781cf67d8df2d7a164acb92b3d065496d5ce00b26cb2c6d217415392e762d59
7ff4ca68ff9bf74954575714914a904309ac06f15ea74e2aef9b3fa02c89ac1a
```

## Stop
When you are done just run stop - docker network will be destroyed and 2 cass clusters too.
```bash
./dualwrite-cass-docker.sh stop
```
```bash
cassandra3x_1
cassandra2x_1
myDWCassNetDocker
```
