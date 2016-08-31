#!/bin/bash

HOSTNAME=$(hostname)
LENGTH=${#HOSTNAME}
POS=`expr index "${HOSTNAME}" -`
MYID=${HOSTNAME:POS:LENGTH-POS}


if [ ! -f /opt/zookeeper/conf/zoo.cfg.dynamic ]; then
  if ! [[ ${MYID} =~ ^[0-9]+$ ]]; then
    MYID="0"
  fi 
  echo "server.${MYID}=${HOSTNAME}:2888:3888;2181" >> /opt/zookeeper/conf/zoo.cfg.dynamic
fi

/opt/zookeeper/bin/zkServer-initialize.sh --force --myid=${MYID}
