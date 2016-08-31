#!/bin/bash

T_HOSTNAME=$(hostname)
T_ID=$( echo ${T_HOSTNAME} | cut -d "-" -f2 | cut -d "-" -f1 )

PEERS=( $(nslookup -type=srv zookeeper.default | grep -oE '[^ ]+$' | grep ^zookeeper*) )

echo ${PEERS[@]}

if [ ${#PEERS[@]} -eq 1 ]; then
  echo "server.${T_ID}=${PEERS[0]}:2888:3888:participant;2181"
else
  for PEER in "${PEERS[@]}"
  do
    P_HOSTNAME=$( echo ${PEER} | cut -d "." -f1 )
    P_ID=$( echo ${P_HOSTNAME} | cut -d "-" -f2 | cut -d "-" -f1 )

    if [[ "${P_HOSTNAME}" == "${T_HOSTNAME}" ]]; then
      echo "server.${P_ID}=${PEER}:2888:3888:observer;2181"
    else
      echo "server.${P_ID}=${PEER}:2888:3888:participant;2181"
    fi
  done
fi

/opt/zookeeper/bin/zkServer-initialize.sh --force --myid=${T_ID}
/opt/zookeeper/bin/zkServer.sh start
/opt/zookeeper/bin/zkCli.sh reconfig -add "server.${T_ID}=${T_HOSTNAME}:2888:3888:participant;2181"
/opt/zookeeper/bin/zkServer.sh stop
