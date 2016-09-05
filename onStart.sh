#!/bin/bash

T_HOSTNAME=$(hostname)
T_ID=$( echo ${T_HOSTNAME} | cut -d "-" -f2 | cut -d "-" -f1 )

PEERS=( $(nslookup -type=srv zookeeper.default | grep -oE '[^ ]+$' | grep ^zookeeper*) )

echo ${PEERS[@]}

if [ ${#PEERS[@]} -eq 0 ]; then
  echo "server.0=localhost:2888:3888:participant;2181" >> /opt/zookeeper/conf/zoo.cfg.dynamic
else
  for PEER in "${PEERS[@]}"
  do
    P_HOSTNAME=$( echo ${PEER} | cut -d "." -f1 )
    P_ID=$( echo ${P_HOSTNAME} | cut -d "-" -f2 | cut -d "-" -f1 )

    echo "server.${P_ID}=${PEER}:2888:3888:participant;2181" >> /opt/zookeeper/conf/zoo.cfg.dynamic
  done

  for PEER in "${PEERS[@]}"
  do
    S_HOSTNAME=$( echo ${PEER} | cut -d "." -f1 )
    S_ID=$( echo ${S_HOSTNAME} | cut -d "-" -f2 | cut -d "-" -f1 )

    if [ "${T_HOSTNAME}" == "${S_HOSTNAME}" ]; then
      /opt/zookeeper/bin/zkServer-initialize.sh --force --myid=${S_ID}
      /opt/zookeeper/bin/zkServer.sh start /opt/zookeeper/conf/zoo.cfg
      /opt/zookeeper/bin/zkCli.sh reconfig -add "server.${S_ID}=${PEER}:2888:3888:participant;2181" quit
      /opt/zookeeper/bin/zkServer.sh stop
    fi
  done
fi

sleep infinity
#/opt/zookeeper/bin/zkServer.sh start-foreground /opt/zookeeper/conf/zoo.cfg
