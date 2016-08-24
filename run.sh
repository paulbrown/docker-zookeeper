#!/bin/bash

HOSTNAME=$(hostname)
LENGTH=${#HOSTNAME}
POS=`expr index "$HOSTNAME" -`

MYID=${HOSTNAME:POS:LENGTH-POS}

/opt/zookeeper/bin/zkServer-initialize.sh --force --myid=$MYID
echo "server.$MYID=$HOSTNAME:2888:3888:participant;2181" >> /opt/zookeeper/conf/zoo.cfg.dynamic
/opt/zookeeper/bin/zkServer.sh start-foreground /opt/zookeeper/conf/zoo.cfg

