#!/bin/bash

T_HOSTNAME=$(hostname)
T_ID=$( echo ${T_HOSTNAME} | cut -d "-" -f2 | cut -d "-" -f1 )

PEERS=( $(nslookup -type=srv zookeeper.default | grep -oE '[^ ]+$' | grep ^zookeeper*) )

echo ${PEERS[@]}

for PEER in "${PEERS[@]}"
do
  P_HOSTNAME=$( echo ${PEER} | cut -d "." -f1 )
  P_ID=$( echo ${P_HOSTNAME} | cut -d "-" -f2 | cut -d "-" -f1 )
  echo "server.${P_ID}=${PEER}:2888:3888:participant;2181" >> /opt/zookeeper/conf/zoo.cfg.dynamic
done

/opt/zookeeper/bin/zkServer-initialize.sh --force --myid=${T_ID}
/opt/zookeeper/bin/zkServer.sh start /opt/zookeeper/conf/zoo.cfg

