#!/bin/bash

: ${ZK_MYID:=1}
: ${ZK_NUMBER_OF_NODES:=1}
: ${ZK_SERVICE_NAME:=zookeeper}

# We do not want to override the dynamic config file.
if [[ ! -f /opt/zookeeper/conf/zoo_dynamic.cfg ]]; then
  for n in $(seq 1 ${ZK_NUMBER_OF_NODES}); do
    echo "server.${n}:${ZK_SERVICE_NAME}-${n}:2888:3888;2181" >> /opt/zookeeper/conf/zoo_dynamic.cfg
  done
fi

echo ${ZK_MYID} > /data/myid

# exec /opt/zookeeper/bin/zkServer.sh start-foreground /opt/zookeeper/conf/zoo.cfg
