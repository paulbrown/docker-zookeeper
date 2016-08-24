#!/bin/bash

HOSTNAME=$(hostname)
LENGTH=${#HOSTNAME}
POS=`expr index "$HOSTNAME" -`

MYID=${HOSTNAME:POS:LENGTH-POS}

exec /opt/zookeeper/bin/zkServer-initialize.sh --force

echo "$MYID" >> /data/myid
echo "server.$MYID=$HOSTNAME:2888:3888:observer;2181" >> /opt/zookeeper/conf/zoo_dynamic.cfg

exec /opt/zookeeper/bin/zkServer.sh start /opt/zookeeper/conf/zoo.cfg
exec /opt/zookeeper/bin/zkCli.sh reconfig -add "server.$MYID=$HOSTNAME:2888:3888:participant;2181"
