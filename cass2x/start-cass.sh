#!/bin/bash

sed -i s/@CASS_NODE_IP/$(hostname -i)/g /cassandra/conf/cassandra.yaml

cd /cassandra/
/cassandra/bin/cassandra -R > /cassandra/cassandra.log

tail -f /cassandra/cassandra.log
