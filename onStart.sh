#!/bin/bash

T_HOSTNAME=$(hostname)
T_ID=$( echo ${T_HOSTNAME} | cut -d "-" -f2 | cut -d "-" -f1 )

PEERS=( $(nslookup -type=srv zookeeper.default | grep -oE '[^ ]+$' | grep ^zookeeper*) )

echo ${PEERS[@]}

for PEER in "${PEERS[@]}"
do
  P_HOSTNAME=$( echo ${PEER} | cut -d "." -f1 )
  P_ID=$( echo ${P_HOSTNAME} | cut -d "-" -f2 | cut -d "-" -f1 )
  if [ "${T_HOSTNAME}" == "${P_HOSTNAME}"; then
    T_CONFIG="server.${P_ID}=${PEER}:2888:3888:participant;2181"
  else
    echo "server.${P_ID}=${PEER}:2888:3888:participant;2181" >> /opt/zookeeper/conf/zoo.cfg.dynamic
  fi
done

/opt/zookeeper/bin/zkServer-initialize.sh --force --myid=${T_ID}
echo ${T_CONFIG} >> /opt/zookeeper/conf/zoo.cfg.dynamic
/opt/zookeeper/bin/zkServer.sh start /opt/zookeeper/conf/zoo.cfg
/opt/zookeeper/bin/zkCli.sh reconfig -add ${T_CONFIG} quit
/opt/zookeeper/bin/zkServer.sh stop
sleep infinity
#/opt/zookeeper/bin/zkServer.sh start-foreground /opt/zookeeper/conf/zoo.cfg
